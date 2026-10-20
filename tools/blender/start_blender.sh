#!/usr/bin/env bash
# Apre Blender con il server dell'add-on "MCP for Blender" in ascolto, così Claude
# può usare gli strumenti del server MCP `blender` (configurato in .mcp.json).
#
# Uso: tools/blender/start_blender.sh [file.blend]
#
# - Se Blender è già in ascolto sulla porta, non fa nulla.
# - Se l'add-on non è installato, lo installa e lo attiva (stessa versione di .mcp.json).
# - Apre Blender staccato dal terminale e aspetta che il server sia pronto.
#   L'add-on avvia il suo server da solo all'apertura (opzione "Auto-Start Server").
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MCP_PACKAGE="mcp-for-blender==2.2.1"   # tenere allineato a .mcp.json
PORT="${BLENDER_PORT:-9876}"
WAIT_SECONDS="${BLENDER_WAIT_SECONDS:-60}"
LOG="${TMPDIR:-/tmp}"; LOG="${LOG%/}/open-space-blender.log"

# Eseguibile: BLENDER_BIN da .env, poi il PATH, poi la posizione standard su macOS.
BLENDER_BIN="${BLENDER_BIN:-}"
if [[ -z "$BLENDER_BIN" && -f "$ROOT/.env" ]]; then
	BLENDER_BIN="$(grep -E '^BLENDER_BIN=' "$ROOT/.env" | tail -1 | cut -d= -f2- || true)"
fi
if [[ -z "$BLENDER_BIN" ]] || ! command -v "$BLENDER_BIN" >/dev/null 2>&1; then
	if command -v blender >/dev/null 2>&1; then
		BLENDER_BIN="blender"
	else
		BLENDER_BIN="/Applications/Blender.app/Contents/MacOS/Blender"
	fi
fi
if [[ ! -x "$BLENDER_BIN" ]] && ! command -v "$BLENDER_BIN" >/dev/null 2>&1; then
	echo "Blender non trovato. Impostate BLENDER_BIN in .env." >&2
	exit 1
fi

port_open() {
	nc -z localhost "$PORT" >/dev/null 2>&1
}

if port_open; then
	echo "Blender è già in ascolto sulla porta $PORT."
	exit 0
fi

# Add-on: cartella delle preferenze di questa versione di Blender (es. 5.2).
VERSION="$("$BLENDER_BIN" --version 2>/dev/null | head -1 | sed -E 's/^Blender ([0-9]+\.[0-9]+).*/\1/')"
ADDON="$HOME/Library/Application Support/Blender/$VERSION/scripts/addons/blender_mcp.py"
if [[ ! -f "$ADDON" ]]; then
	echo "Installo l'add-on MCP for Blender per Blender $VERSION..."
	DISABLE_TELEMETRY=true uvx "$MCP_PACKAGE" install-addon
fi
# Attiva l'add-on se non lo è (salva solo le preferenze, non tocca le scene).
"$BLENDER_BIN" -b -noaudio --python-expr "
import bpy, addon_utils
if not addon_utils.check('blender_mcp')[1]:
    bpy.ops.preferences.addon_enable(module='blender_mcp')
    bpy.ops.wm.save_userpref()
    print('BLENDER_MCP_ENABLED')
" 2>/dev/null | grep -q BLENDER_MCP_ENABLED && echo "Add-on attivato." || true

echo "Apro Blender (log: $LOG)..."
# Niente controllo degli aggiornamenti dell'add-on: la versione è fissata in .mcp.json.
BLENDERMCP_NO_UPDATE_CHECK=1 nohup "$BLENDER_BIN" "$@" >"$LOG" 2>&1 &
disown

for ((i = 0; i < WAIT_SECONDS; i++)); do
	if port_open; then
		echo "Blender pronto: server MCP in ascolto sulla porta $PORT."
		exit 0
	fi
	sleep 1
done

echo "Blender aperto, ma il server non risponde sulla porta $PORT dopo ${WAIT_SECONDS} s." >&2
echo "In Blender: tasto N nella vista 3D, scheda MCP for Blender, Start MCP Server. Log: $LOG" >&2
exit 1
