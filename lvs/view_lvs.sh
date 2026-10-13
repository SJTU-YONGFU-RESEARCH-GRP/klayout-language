#!/usr/bin/env bash
# Open layout + LVS database in the KLayout GUI.
#
# Usage:
#   ./view_lvs.sh            # run GOOD LVS first, then open GUI
#   ./view_lvs.sh --bad      # run/open BAD result
#   ./view_lvs.sh --no-lvs   # open existing files only

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/nmos_demo.gds"
TAG="good"
CELL="NMOS_GOOD"
RUN_LVS=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bad) TAG="bad"; CELL="NMOS_BAD" ;;
    --good) TAG="good"; CELL="NMOS_GOOD" ;;
    --no-lvs) RUN_LVS=0 ;;
    -h|--help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

LVSDB="${ROOT}/nmos_${TAG}.lvsdb"

if ! command -v klayout >/dev/null 2>&1; then
  echo "ERROR: klayout not found on PATH" >&2
  exit 1
fi

if [[ "$RUN_LVS" -eq 1 ]]; then
  if [[ "$TAG" == "good" ]]; then
    "${ROOT}/run_lvs.sh" --lvs-only --good || true
  else
    "${ROOT}/run_lvs.sh" --lvs-only --bad || true
  fi
fi

[[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS}" >&2; exit 1; }
[[ -f "$LVSDB" ]] || { echo "ERROR: missing ${LVSDB} (run ./run_lvs.sh first)" >&2; exit 1; }

echo "==> klayout ${GDS} -mn ${LVSDB}  (cell ${CELL})"
# -mn loads an L2N / LVS database into the previous layout view
exec klayout "$GDS" -mn "$LVSDB"
