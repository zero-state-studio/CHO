#!/usr/bin/env bash
# headersHelper del server MCP `scenario` (vedi .mcp.json): Claude Code lo esegue a ogni
# connessione, dalla radice del progetto, e usa come header il JSON che stampa.
#
# - Con SCENARIO_API_KEY e SCENARIO_API_SECRET in .env: autenticazione Basic con la chiave.
# - Senza: nessun header, e il server MCP chiede il login dal browser (OAuth).
#
# Stampa solo il JSON degli header: mai la chiave in chiaro, mai messaggi su stdout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="$ROOT/.env"

# Legge una variabile da .env senza eseguire il file; toglie spazi e virgolette.
read_env() {
	[[ -f "$ENV_FILE" ]] || return 0
	grep -E "^[[:space:]]*$1=" "$ENV_FILE" | tail -1 | cut -d= -f2- \
		| sed -E "s/^[[:space:]]*//; s/[[:space:]]*$//; s/^\"(.*)\"$/\1/; s/^'(.*)'$/\1/"
}

KEY="$(read_env SCENARIO_API_KEY)"
SECRET="$(read_env SCENARIO_API_SECRET)"

if [[ -n "$KEY" && -n "$SECRET" ]]; then
	TOKEN="$(printf '%s:%s' "$KEY" "$SECRET" | base64 | tr -d '\n')"
	printf '{"Authorization": "Basic %s"}\n' "$TOKEN"
else
	printf '{}\n'
fi
