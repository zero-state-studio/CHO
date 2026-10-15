"""Controlla che le chiavi delle API in .env funzionino, con chiamate gratuite.

Uso: tools/.venv/bin/python tools/check_keys.py

Stampa solo esito, piano e crediti di ogni servizio: mai il valore delle chiavi.
"""

from __future__ import annotations

import sys
from typing import Callable

import requests

from common.env import is_set, load_env, require

TIMEOUT_SECONDS: float = 20.0

MESHY_BALANCE_URL: str = "https://api.meshy.ai/openapi/v1/balance"
ELEVENLABS_SUBSCRIPTION_URL: str = "https://api.elevenlabs.io/v1/user/subscription"
# Scenario non documenta un endpoint pubblico per i crediti: leggere un modello
# è gratuito e basta a verificare chiave e segreto.
SCENARIO_MODELS_URL: str = "https://api.cloud.scenario.com/v1/models"

REQUIRED_VARIABLES: tuple[str, ...] = (
    "ELEVENLABS_API_KEY",
    "MESHY_API_KEY",
    "SCENARIO_API_KEY",
    "SCENARIO_API_SECRET",
)


def check_meshy() -> str:
    response = requests.get(
        MESHY_BALANCE_URL,
        headers={"Authorization": f"Bearer {require('MESHY_API_KEY')}"},
        timeout=TIMEOUT_SECONDS,
    )
    response.raise_for_status()
    data: dict = response.json()
    return (
        f"saldo {data.get('balance')} crediti "
        f"(mensili {data.get('monthly_credits')}, permanenti {data.get('permanent_credits')})"
    )


def check_elevenlabs() -> str:
    response = requests.get(
        ELEVENLABS_SUBSCRIPTION_URL,
        headers={"xi-api-key": require("ELEVENLABS_API_KEY")},
        timeout=TIMEOUT_SECONDS,
    )
    response.raise_for_status()
    data: dict = response.json()
    used: int = int(data.get("character_count", 0))
    limit: int = int(data.get("character_limit", 0))
    return f"piano {data.get('tier')}, crediti usati {used} su {limit} (restano {limit - used})"


def check_scenario() -> str:
    response = requests.get(
        SCENARIO_MODELS_URL,
        params={"pageSize": 1},
        auth=(require("SCENARIO_API_KEY"), require("SCENARIO_API_SECRET")),
        timeout=TIMEOUT_SECONDS,
    )
    response.raise_for_status()
    return "autenticazione riuscita (crediti da leggere nella dashboard di Scenario)"


def main() -> int:
    load_env()
    missing: list[str] = [name for name in REQUIRED_VARIABLES if not is_set(name)]
    if missing:
        print("Variabili vuote in .env: " + ", ".join(missing))
        return 1

    checks: dict[str, Callable[[], str]] = {
        "Meshy": check_meshy,
        "ElevenLabs": check_elevenlabs,
        "Scenario": check_scenario,
    }
    failures: int = 0
    for service, check in checks.items():
        try:
            print(f"{service}: OK, {check()}")
        except requests.HTTPError as error:
            failures += 1
            # Solo il codice HTTP: il corpo della risposta potrebbe riportare la chiave.
            print(f"{service}: ERRORE HTTP {error.response.status_code}")
        except requests.RequestException as error:
            failures += 1
            print(f"{service}: ERRORE di rete ({type(error).__name__})")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
