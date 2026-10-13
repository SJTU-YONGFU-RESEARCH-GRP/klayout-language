#!/usr/bin/env bash
# Open demo layout + KLayout DRC report (RDB) in the GUI.
#
# Usage:
#   ./view_klayout_drc.sh            # DEMO report (run DRC first)
#   ./view_klayout_drc.sh --good
#   ./view_klayout_drc.sh --bad
#   ./view_klayout_drc.sh --no-drc   # open existing GDS + RDB only

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/m1_contact_demo.gds"

WHICH="demo"
RUN_DRC=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --good) WHICH="good" ;;
    --bad) WHICH="bad" ;;
    --demo) WHICH="demo" ;;
    --no-drc) RUN_DRC=0 ;;
    -h|--help)
      sed -n '2,9p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

RDB="${ROOT}/m1_contact_${WHICH}.lyrdb"
# Legacy alias
if [[ "$WHICH" == "demo" ]]; then
  LEGACY="${ROOT}/m1_contact.lyrdb"
fi

if ! command -v klayout >/dev/null 2>&1; then
  echo "ERROR: klayout not found on PATH" >&2
  exit 1
fi

if [[ "$RUN_DRC" -eq 1 ]]; then
  case "$WHICH" in
    good) "${ROOT}/run_klayout_drc.sh" --drc-only --good ;;
    bad)  "${ROOT}/run_klayout_drc.sh" --drc-only --bad ;;
    *)    "${ROOT}/run_klayout_drc.sh" --drc-only --demo ;;
  esac
fi

[[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS}" >&2; exit 1; }
if [[ ! -f "$RDB" && -n "${LEGACY:-}" && -f "$LEGACY" ]]; then
  RDB="$LEGACY"
fi
[[ -f "$RDB" ]] || { echo "ERROR: missing ${RDB}" >&2; exit 1; }

echo "==> klayout ${GDS} -m ${RDB}"
exec klayout "$GDS" -m "$RDB"
