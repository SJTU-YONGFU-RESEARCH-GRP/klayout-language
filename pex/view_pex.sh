#!/usr/bin/env bash
# Open PEX demo layout in KLayout and print the last extract report.
#
# Usage:
#   ./view_pex.sh              # R_GOOD report + GDS
#   ./view_pex.sh --r-bad
#   ./view_pex.sh --c          # C_GOOD
#   ./view_pex.sh --c-bad
#   ./view_pex.sh --demo       # PEX_DEMO topcell
#   ./view_pex.sh --no-pex

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/pex_demo.gds"
TAG="r_good"
RUN_PEX=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --good|--r|--r-good) TAG="r_good" ;;
    --bad|--r-bad) TAG="r_bad" ;;
    --c|--c-good) TAG="c_good" ;;
    --c-bad) TAG="c_bad" ;;
    --demo) TAG="demo" ;;
    --no-pex) RUN_PEX=0 ;;
    -h|--help)
      sed -n '2,12p' "$0"
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
  case "$TAG" in
    r_good) "${ROOT}/run_pex.sh" --pex-only --r --good || true ;;
    r_bad)  "${ROOT}/run_pex.sh" --pex-only --r --bad || true ;;
    c_good) "${ROOT}/run_pex.sh" --pex-only --c --good || true ;;
    c_bad)  "${ROOT}/run_pex.sh" --pex-only --c --bad || true ;;
  esac
fi

[[ -f "$GDS" ]] || [[ -f "${ROOT}/r_demo.gds" ]] || { echo "ERROR: missing GDS" >&2; exit 1; }
[[ -f "$GDS" ]] || GDS="${ROOT}/r_demo.gds"

case "$TAG" in
  r_good) REPORT="${ROOT}/r_good.txt" ;;
  r_bad)  REPORT="${ROOT}/r_bad.txt" ;;
  c_good) REPORT="${ROOT}/c_good.txt" ;;
  c_bad)  REPORT="${ROOT}/c_bad.txt" ;;
  *)      REPORT="" ;;
esac

if [[ -n "$REPORT" && -f "$REPORT" ]]; then
  echo "==> Last report (${REPORT}):"
  sed 's/^/    /' "$REPORT" || true
fi

echo "==> klayout ${GDS}"
exec klayout "$GDS"
