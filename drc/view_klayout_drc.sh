#!/usr/bin/env bash
# Open demo layout + KLayout DRC report (RDB) in the GUI.
#
# Usage:
#   ./view_klayout_drc.sh            # run DRC first, then open GUI
#   ./view_klayout_drc.sh --no-drc   # open existing GDS + RDB only

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/m1_contact_demo.gds"
RDB="${ROOT}/m1_contact.lyrdb"

RUN_DRC=1
if [[ "${1:-}" == "--no-drc" ]]; then
  RUN_DRC=0
fi

if ! command -v klayout >/dev/null 2>&1; then
  echo "ERROR: klayout not found on PATH" >&2
  exit 1
fi

if [[ "$RUN_DRC" -eq 1 ]]; then
  "${ROOT}/run_demo.sh" --drc-only
fi

[[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS}" >&2; exit 1; }
[[ -f "$RDB" ]] || { echo "ERROR: missing ${RDB}" >&2; exit 1; }

echo "==> klayout ${GDS} -m ${RDB}"
exec klayout "$GDS" -m "$RDB"
