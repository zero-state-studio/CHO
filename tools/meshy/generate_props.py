"""Genera con Meshy (Text to 3D) gli oggetti del livello demo.

Per ogni oggetto: forma a pochi poligoni (preview, Smart Topology), poi texture
(refine). Il .glb grezzo e i dati del task vanno in source_assets/ai_raw/meshy/,
la copia in assets/models/props/prop_<id>.glb, e l'asset entra nel registro.

Uso:
    # Prova a secco (default): mostra prompt, impostazioni e crediti, non spende nulla
    tools/.venv/bin/python tools/meshy/generate_props.py --only desk,swivel_chair

    # Generazione vera, solo dopo l'ok del team
    tools/.venv/bin/python tools/meshy/generate_props.py --only desk,swivel_chair --run

    # Rifare solo la texture partendo da una forma (preview) già pagata
    tools/.venv/bin/python tools/meshy/generate_props.py --only task_stack --preview-id <id> --run

Prompt e impostazioni stanno in tools/meshy/prompts.json.
"""

from __future__ import annotations

import argparse
import csv
import json
import shutil
import struct
import sys
import time
from datetime import date
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from common.credits import check as check_credits  # noqa: E402
from common.env import PROJECT_ROOT, require  # noqa: E402

API_BASE: str = "https://api.meshy.ai/openapi"
TEXT_TO_3D_URL: str = f"{API_BASE}/v2/text-to-3d"
BALANCE_URL: str = f"{API_BASE}/v1/balance"
PROMPTS_FILE: Path = Path(__file__).with_name("prompts.json")
RAW_DIR: Path = PROJECT_ROOT / "source_assets" / "ai_raw" / "meshy"
PROPS_DIR: Path = PROJECT_ROOT / "assets" / "models" / "props"
REGISTRY_FILE: Path = PROJECT_ROOT / "docs" / "registro-asset.csv"
GENERATED_BY: str = "Claude Code (tools/meshy/generate_props.py)"
POLL_SECONDS: float = 10.0
TASK_TIMEOUT_SECONDS: float = 900.0
REQUEST_TIMEOUT_SECONDS: float = 60.0


def load_config() -> dict:
    return json.loads(PROMPTS_FILE.read_text(encoding="utf-8"))


def full_prompt(config: dict, prop: dict) -> str:
    return f"{prop['prompt']} {config['style_prompt']}"


def preview_payload(config: dict, prop: dict) -> dict:
    payload: dict = {"mode": "preview", "prompt": full_prompt(config, prop)}
    payload.update(config["preview"])
    payload["target_polycount"] = prop["target_polycount"]
    return payload


def full_texture_prompt(config: dict, prop: dict) -> str:
    """Colori dell'oggetto (se indicati) seguiti dalle regole comuni della texture."""
    colors: str = prop.get("texture_prompt", "")
    return f"{colors} {config['texture_prompt']}".strip()


def refine_payload(config: dict, prop: dict, preview_task_id: str) -> dict:
    payload: dict = {
        "mode": "refine",
        "preview_task_id": preview_task_id,
        "texture_prompt": full_texture_prompt(config, prop),
    }
    payload.update(config["refine"])
    return payload


def credits_per_prop(config: dict) -> int:
    return int(config["credits"]["preview"]) + int(config["credits"]["refine"])


# --- API ---------------------------------------------------------------------

def headers() -> dict:
    return {"Authorization": f"Bearer {require('MESHY_API_KEY')}"}


def get_balance() -> int:
    response = requests.get(BALANCE_URL, headers=headers(), timeout=REQUEST_TIMEOUT_SECONDS)
    response.raise_for_status()
    return int(response.json()["balance"])


def create_task(payload: dict) -> str:
    response = requests.post(TEXT_TO_3D_URL, headers=headers(), json=payload, timeout=REQUEST_TIMEOUT_SECONDS)
    if not response.ok:
        # Il corpo degli errori di Meshy spiega il parametro sbagliato e non contiene la chiave.
        sys.exit(f"Meshy ha rifiutato il task (HTTP {response.status_code}): {response.text[:500]}")
    return str(response.json()["result"])


def wait_task(task_id: str, label: str) -> dict:
    started: float = time.monotonic()
    while True:
        response = requests.get(f"{TEXT_TO_3D_URL}/{task_id}", headers=headers(), timeout=REQUEST_TIMEOUT_SECONDS)
        response.raise_for_status()
        task: dict = response.json()
        status: str = task["status"]
        print(f"    {label}: {status} {task.get('progress', 0)}%")
        if status == "SUCCEEDED":
            return task
        if status in ("FAILED", "CANCELED"):
            message: str = (task.get("task_error") or {}).get("message", "")
            sys.exit(f"Task {task_id} ({label}) terminato con {status}: {message}")
        if time.monotonic() - started > TASK_TIMEOUT_SECONDS:
            # Il task resta in corso su Meshy: non va ricreato, si riprende con lo stesso id.
            sys.exit(f"Task {task_id} ({label}) ancora in corso dopo {TASK_TIMEOUT_SECONDS:.0f} s: "
                     "controllalo sulla dashboard di Meshy, non rigenerarlo.")
        time.sleep(POLL_SECONDS)


def download(url: str, destination: Path) -> None:
    response = requests.get(url, timeout=REQUEST_TIMEOUT_SECONDS)
    response.raise_for_status()
    destination.write_bytes(response.content)


# --- GLB ---------------------------------------------------------------------

def count_glb_triangles(path: Path) -> int:
    """Conta i triangoli di un .glb leggendo il chunk JSON (indici o vertici)."""
    data: bytes = path.read_bytes()
    json_length: int = struct.unpack_from("<I", data, 12)[0]
    gltf: dict = json.loads(data[20:20 + json_length])
    accessors: list = gltf.get("accessors", [])
    triangles: int = 0
    for mesh in gltf.get("meshes", []):
        for primitive in mesh.get("primitives", []):
            if primitive.get("mode", 4) != 4:
                continue
            if "indices" in primitive:
                triangles += accessors[primitive["indices"]]["count"] // 3
            else:
                triangles += accessors[primitive["attributes"]["POSITION"]]["count"] // 3
    return triangles


# --- Registro ----------------------------------------------------------------

def append_registry(file_name: str, prompt: str, note: str) -> None:
    with REGISTRY_FILE.open("a", newline="", encoding="utf-8") as handle:
        csv.writer(handle, lineterminator="\n").writerow([file_name, "Meshy (Text to 3D)", prompt, date.today().isoformat(),
                                     GENERATED_BY, "", note])


# --- Main --------------------------------------------------------------------

def ensure_credits(cost: int) -> None:
    """Si ferma se la spesa farebbe scendere i crediti sotto la riserva (tools/credit_limits.json)."""
    verdict = check_credits("meshy", cost)
    print(f"    {verdict.message}")
    if not verdict.allowed:
        sys.exit("Limite dei crediti raggiunto: nessun task creato.")


def generate(config: dict, prop: dict, existing_preview_id: str | None = None) -> dict:
    prop_id: str = prop["id"]
    print(f"\n== {prop_id}")
    # Ricontrollo a ogni oggetto: nel frattempo qualcun altro del team può aver speso.
    ensure_credits(int(config["credits"]["refine"]) if existing_preview_id else credits_per_prop(config))
    started: float = time.monotonic()

    if existing_preview_id:
        # Forma già pagata: si rifà solo la texture, senza ricreare la preview.
        preview_id: str = existing_preview_id
        preview_task: dict = wait_task(preview_id, "preview esistente")
        preview_task["consumed_credits"] = 0
    else:
        preview_id = create_task(preview_payload(config, prop))
        print(f"    preview creato: {preview_id}")
        preview_task = wait_task(preview_id, "preview")

    refine_id: str = create_task(refine_payload(config, prop, preview_id))
    print(f"    refine creato: {refine_id}")
    refine_task: dict = wait_task(refine_id, "refine")

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    PROPS_DIR.mkdir(parents=True, exist_ok=True)
    stamp: str = date.today().strftime("%Y%m%d")
    raw_glb: Path = RAW_DIR / f"{prop_id}_{stamp}_{refine_id[:8]}.glb"
    download(refine_task["model_urls"]["glb"], raw_glb)
    final_glb: Path = PROPS_DIR / f"prop_{prop_id}.glb"
    shutil.copyfile(raw_glb, final_glb)

    elapsed: float = time.monotonic() - started
    credits: int = int(preview_task.get("consumed_credits") or 0) + int(refine_task.get("consumed_credits") or 0)
    triangles: int = count_glb_triangles(final_glb)
    over_budget: bool = triangles > int(config["triangle_budget"])
    # Dati del task senza gli URL firmati, che scadono e non servono.
    metadata: dict = {
        "prop": prop_id,
        "preview_task_id": preview_id,
        "refine_task_id": refine_id,
        "preview_payload": preview_payload(config, prop),
        "refine_payload": refine_payload(config, prop, preview_id),
        "consumed_credits": credits,
        "elapsed_seconds": round(elapsed),
        "triangles": triangles,
        "raw_file": raw_glb.name,
    }
    raw_glb.with_suffix(".json").write_text(json.dumps(metadata, indent=2, ensure_ascii=False), encoding="utf-8")
    note: str = (f"preview {config['preview']['ai_model']} + refine {config['refine']['ai_model']}; "
                 f"{credits} crediti; {round(elapsed)} s; {triangles} triangoli"
                 + ("; SOPRA IL BUDGET" if over_budget else ""))
    append_registry(f"assets/models/props/{final_glb.name}", full_prompt(config, prop), note)
    print(f"    fatto: {final_glb.relative_to(PROJECT_ROOT)} ({triangles} triangoli, {credits} crediti, "
          f"{round(elapsed)} s){'  <-- SOPRA IL BUDGET' if over_budget else ''}")
    return metadata


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--only", help="id degli oggetti separati da virgola (default: tutti)")
    parser.add_argument("--run", action="store_true", help="genera davvero e spende crediti")
    parser.add_argument("--preview-id", help="riusa questa preview già riuscita (un solo oggetto): solo refine")
    args = parser.parse_args()

    config: dict = load_config()
    props: list[dict] = config["props"]
    if args.only:
        wanted: list[str] = [item.strip() for item in args.only.split(",") if item.strip()]
        unknown: list[str] = [item for item in wanted if item not in {prop["id"] for prop in props}]
        if unknown:
            sys.exit(f"Oggetti sconosciuti: {', '.join(unknown)}")
        props = [prop for prop in props if prop["id"] in wanted]

    if args.preview_id and len(props) != 1:
        sys.exit("--preview-id vale per un solo oggetto: usalo con --only <id>.")
    estimate: int = int(config["credits"]["refine"]) if args.preview_id else credits_per_prop(config) * len(props)
    print(f"Oggetti: {len(props)}  |  stima: {estimate} crediti "
          f"({config['credits']['preview']} preview + {config['credits']['refine']} refine a oggetto)")
    for prop in props:
        print(f"\n[{prop['id']}] target_polycount={prop['target_polycount']}")
        print(f"  prompt: {full_prompt(config, prop)}")
        print(f"  texture_prompt: {full_texture_prompt(config, prop)}")
    print(f"preview: {json.dumps(config['preview'])}")
    print(f"refine:  {json.dumps(config['refine'])}")

    print()
    if not args.run:
        print(f"    {check_credits('meshy', estimate).message}")
        print("Prova a secco: nessun task creato. Aggiungi --run per generare.")
        return 0
    ensure_credits(estimate)

    results: list[dict] = [generate(config, prop, args.preview_id) for prop in props]
    total_credits: int = sum(result["consumed_credits"] for result in results)
    print(f"\nTotale: {total_credits} crediti; saldo ora {get_balance()}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
