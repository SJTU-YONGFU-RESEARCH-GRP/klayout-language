#!/usr/bin/env bash
# Open PEX demo layout in the KLayout GUI (and print last extract report).
#
# Usage:
#   ./view_pex.sh            # run GOOD extract, open GDS
#   ./view_pex.sh --bad
#   ./view_pex.sh --demo     # open R_DEMO topcell
#   ./view_pex.sh --no-pex   # open existing GDS only

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/r_demo.gds"
TAG="good"
RUN_PEX=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bad) TAG="bad" ;;
    --good) TAG="good" ;;
    --demo) TAG="demo" ;;
    --no-pex) RUN_PEX=0 ;;
    -h|--help)
      sed -n '2,9p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

if ! command -v klayout >/dev/null 2>&1; then
  echo "ERROR: klayout not found on PATH" >&2
  exit 1
fi

if [[ "$RUN_PEX" -eq 1 && "$TAG" != "demo" ]]; then
  if [[ "$TAG" == "good" ]]; then
    "${ROOT}/run_pex.sh" --pex-only --good || true
  else
    "${ROOT}/run_pex.sh" --pex-only --bad || true
  fi
fi

[[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS}" >&2; exit 1; }

REPORT="${ROOT}/r_${TAG}.txt"
if [[ -f "$REPORT" ]]; then
  echo "==> Last report (${REPORT}):"
  sed 's/^/    /' "$REPORT" || true
fi

echo "==> klayout ${GDS}"
exec klayout "$GDS"
