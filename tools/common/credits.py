"""Guardia dei crediti: nessuna generazione può far scendere i crediti sotto la riserva.

I limiti stanno in tools/credit_limits.json; i crediti rimasti si leggono dal vivo dalle
API di ogni servizio. Usa solo la libreria standard, perché lo importa anche l'hook di
Claude Code (.claude/hooks/credit_guard.py), che gira fuori dall'ambiente virtuale.

I valori delle chiavi non vengono mai stampati.
"""

from __future__ import annotations

import base64
import json
import os
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path

PROJECT_ROOT: Path = Path(__file__).resolve().parents[2]
ENV_FILE: Path = PROJECT_ROOT / ".env"
LIMITS_FILE: Path = PROJECT_ROOT / "tools" / "credit_limits.json"
TIMEOUT_SECONDS: float = 20.0

MESHY_BALANCE_URL: str = "https://api.meshy.ai/openapi/v1/balance"
ELEVENLABS_SUBSCRIPTION_URL: str = "https://api.elevenlabs.io/v1/user/subscription"
SCENARIO_TEAM_URL: str = "https://api.cloud.scenario.com/v1/teams/{team_id}"

SERVICES: tuple[str, ...] = ("meshy", "elevenlabs", "scenario")


class CreditsUnavailable(Exception):
    """I crediti rimasti non si possono leggere: per sicurezza si blocca tutto."""


@dataclass(frozen=True)
class Verdict:
    allowed: bool
    message: str


def load_limits() -> dict:
    return json.loads(LIMITS_FILE.read_text(encoding="utf-8"))


def env_value(name: str) -> str:
    """Valore da .env, che vince sulla shell; altrimenti dalla shell. Mai stampato."""
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
            stripped: str = line.strip()
            if stripped.startswith("#") or "=" not in stripped:
                continue
            key, value = stripped.split("=", 1)
            if key.strip() == name:
                value = value.strip().strip('"').strip("'")
                if value:
                    return value
    return os.environ.get(name, "").strip()


def _get_json(url: str, headers: dict[str, str]) -> dict:
    request = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT_SECONDS) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        # Solo il codice HTTP: il corpo della risposta potrebbe riportare la chiave.
        raise CreditsUnavailable(f"HTTP {error.code}") from None
    except (urllib.error.URLError, TimeoutError) as error:
        raise CreditsUnavailable(f"errore di rete ({type(error).__name__})") from None


def remaining(service: str, limits: dict | None = None) -> int:
    """Crediti rimasti del piano, letti dal vivo. Solleva CreditsUnavailable se non si può."""
    limits = limits or load_limits()
    if service == "meshy":
        key: str = env_value("MESHY_API_KEY")
        if not key:
            raise CreditsUnavailable("MESHY_API_KEY vuota in .env")
        return int(_get_json(MESHY_BALANCE_URL, {"Authorization": f"Bearer {key}"})["balance"])
    if service == "elevenlabs":
        key = env_value("ELEVENLABS_API_KEY")
        if not key:
            raise CreditsUnavailable("ELEVENLABS_API_KEY vuota in .env")
        data: dict = _get_json(ELEVENLABS_SUBSCRIPTION_URL, {"xi-api-key": key})
        return int(data.get("character_limit", 0)) - int(data.get("character_count", 0))
    if service == "scenario":
        key = env_value("SCENARIO_API_KEY")
        secret: str = env_value("SCENARIO_API_SECRET")
        if not key or not secret:
            raise CreditsUnavailable("SCENARIO_API_KEY o SCENARIO_API_SECRET vuote in .env")
        config: dict = limits["scenario"]
        token: str = base64.b64encode(f"{key}:{secret}".encode()).decode()
        team: dict = _get_json(
            SCENARIO_TEAM_URL.format(team_id=config["team_id"]), {"Authorization": f"Basic {token}"}
        )["team"]
        consumed: int = sum(int(user.get("consumption", 0)) for user in team.get("users", []))
        consumed += sum(int(api_key.get("consumption", 0)) for api_key in team.get("keys", []))
        return int(config["monthly_allowance"]) - consumed
    raise ValueError(f"Servizio sconosciuto: {service}")


def check(service: str, cost: int) -> Verdict:
    """Dice se una spesa di `cost` crediti lascia intatta la riserva del servizio."""
    limits: dict = load_limits()
    config: dict = limits[service]
    unit: str = config["unit"]
    reserve: int = int(config["reserve"])
    try:
        left: int = remaining(service, limits)
    except CreditsUnavailable as error:
        return Verdict(False, f"{service}: crediti rimasti non leggibili ({error}), generazione bloccata")
    spendable: int = left - reserve
    summary: str = (
        f"{service}: costo {cost} {unit}, rimasti {left}, riserva {reserve}, spendibili {max(spendable, 0)}"
    )
    if cost > spendable:
        return Verdict(False, f"{summary}: OLTRE IL LIMITE, generazione bloccata")
    return Verdict(True, summary)
