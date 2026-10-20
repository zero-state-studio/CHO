"""Hook di Claude Code: nessuno strumento MCP a pagamento può superare i limiti dei crediti.

PreToolUse:
- Meshy (MCP): bloccati tutti gli strumenti a pagamento. Meshy si usa solo da
  tools/meshy/, dove la guardia dei crediti controlla ogni task.
- Pixellab (MCP): bloccate le generazioni, il progetto non lo usa.
- Blender (MCP): bloccato generate_3d (integrazioni a pagamento del pannello).
- Scenario model_run / workflow_run: le stime (dry_run) passano. Una generazione vera
  passa solo se c'è una stima recente con gli stessi parametri e se il costo lascia
  intatta la riserva (tools/credit_limits.json); poi chiede comunque conferma.
- Scenario scenario_tool_execute_write: chiede conferma, e blocca se la riserva è finita.

PostToolUse: salva il costo delle stime di Scenario, per il controllo qui sopra.

In caso di errore imprevisto su uno strumento sorvegliato, blocca: mai spendere alla cieca.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
import tempfile
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
from common.credits import check  # noqa: E402

ESTIMATES_FILE: Path = Path(tempfile.gettempdir()) / "open-space-scenario-estimates.json"
ESTIMATE_MAX_AGE_SECONDS: float = 3600.0

MESHY_FREE_TOOLS: frozenset[str] = frozenset({
    "meshy_check_balance", "meshy_list_usage", "meshy_get_task_status", "meshy_list_tasks",
    "meshy_list_models", "meshy_download_model", "meshy_list_animations",
    "meshy_analyze_printability", "meshy_cancel_task",
})
PIXELLAB_FREE_PREFIXES: tuple[str, ...] = ("get_", "list_", "search_", "view_", "wait_", "cancel_")
SCENARIO_RUN_TOOLS: frozenset[str] = frozenset({"model_run", "workflow_run"})
# Campi che non cambiano il costo: esclusi dall'impronta della richiesta.
IGNORED_FIELDS: frozenset[str] = frozenset({"team_id", "project_id", "wait", "response_format", "dry_run"})


def decide(decision: str, reason: str) -> None:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
            "permissionDecisionReason": reason,
        }
    }))


def fingerprint(tool: str, tool_input: dict) -> str:
    relevant: dict = {key: value for key, value in tool_input.items() if key not in IGNORED_FIELDS}
    payload: str = json.dumps({"tool": tool, "input": relevant}, sort_keys=True, ensure_ascii=False)
    return hashlib.sha256(payload.encode()).hexdigest()


def load_estimates() -> dict:
    try:
        estimates: dict = json.loads(ESTIMATES_FILE.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}
    now: float = time.time()
    return {key: value for key, value in estimates.items() if now - value["time"] < ESTIMATE_MAX_AGE_SECONDS}


def save_estimate(key: str, cost: int) -> None:
    estimates: dict = load_estimates()
    estimates[key] = {"cost": cost, "time": time.time()}
    ESTIMATES_FILE.write_text(json.dumps(estimates), encoding="utf-8")


def pre_tool_use(service: str, tool: str, tool_input: dict) -> None:
    if service == "meshy" and tool not in MESHY_FREE_TOOLS:
        decide("deny", "Meshy dall'MCP è bloccato: si usa solo tools/meshy/generate_props.py, "
                       "che controlla i crediti a ogni task (tools/credit_limits.json).")
    elif service == "pixellab" and not tool.startswith(PIXELLAB_FREE_PREFIXES):
        decide("deny", "Pixellab non fa parte del progetto: le generazioni sono bloccate.")
    elif service == "blender" and tool == "generate_3d":
        decide("deny", "Le generazioni a pagamento del pannello di Blender sono bloccate: "
                       "gli oggetti 3D si generano con tools/meshy/.")
    elif service == "scenario" and tool in SCENARIO_RUN_TOOLS:
        if tool_input.get("dry_run") is True:
            return
        estimate: dict | None = load_estimates().get(fingerprint(tool, tool_input))
        if estimate is None:
            decide("deny", "Prima una stima con dry_run=true e gli stessi identici parametri: "
                           "senza costo stimato la generazione è bloccata.")
            return
        verdict = check("scenario", int(estimate["cost"]))
        if not verdict.allowed:
            decide("deny", verdict.message)
        else:
            decide("ask", f"Generazione Scenario a pagamento. {verdict.message}")
    elif service == "scenario" and tool == "scenario_tool_execute_write":
        verdict = check("scenario", 0)
        if not verdict.allowed:
            decide("deny", verdict.message)
        else:
            decide("ask", f"Strumento Scenario in scrittura: può consumare CU. {verdict.message}")


def post_tool_use(service: str, tool: str, tool_input: dict, tool_response: object) -> None:
    if service != "scenario" or tool not in SCENARIO_RUN_TOOLS or tool_input.get("dry_run") is not True:
        return
    match = re.search(r'creativeUnitsCost\\*"\s*:\s*(\d+)', json.dumps(tool_response))
    if match:
        save_estimate(fingerprint(tool, tool_input), int(match.group(1)))


def main() -> int:
    event: dict = json.load(sys.stdin)
    parts: list[str] = str(event.get("tool_name", "")).split("__", 2)
    if len(parts) != 3 or parts[0] != "mcp":
        return 0
    _, service, tool = parts
    tool_input: dict = event.get("tool_input") or {}
    if event.get("hook_event_name") == "PostToolUse":
        post_tool_use(service, tool, tool_input, event.get("tool_response"))
        return 0
    try:
        pre_tool_use(service, tool, tool_input)
    except Exception as error:  # noqa: BLE001 — su uno strumento sorvegliato si blocca sempre
        decide("deny", f"Guardia dei crediti non disponibile ({type(error).__name__}): bloccato per sicurezza.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
