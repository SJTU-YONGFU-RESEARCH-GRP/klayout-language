#!/usr/bin/env bash
# Open PEX demo layout in KLayout and print the last extract report.
#
# Usage:
#   ./view_pex.sh              # R_GOOD report + GDS
#   ./view_pex.sh --r-bad
#   ./view_pex.sh --c          # C_GOOD
#   ./view_pex.sh --c-bad
#   ./view_pex.sh --cc         # CC_GOOD (kpex)
#   ./view_pex.sh --cc-bad
#   ./view_pex.sh --cc-demo    # CC_DEMO topcell
#   ./view_pex.sh --demo       # R/C demo topcell
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
    --cc|--cc-good) TAG="cc_good" ;;
    --cc-bad) TAG="cc_bad" ;;
    --cc-demo) TAG="cc_demo" ;;
    --demo) TAG="demo" ;;
    --no-pex) RUN_PEX=0 ;;
    -h|--help)
      sed -n '2,16p' "$0"
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

if [[ "$RUN_PEX" -eq 1 && "$TAG" != "demo" && "$TAG" != "cc_demo" ]]; then
  case "$TAG" in
    r_good) "${ROOT}/run_pex.sh" --pex-only --r --good || true ;;
    r_bad)  "${ROOT}/run_pex.sh" --pex-only --r --bad || true ;;
    c_good) "${ROOT}/run_pex.sh" --pex-only --c --good || true ;;
    c_bad)  "${ROOT}/run_pex.sh" --pex-only --c --bad || true ;;
    cc_good) "${ROOT}/run_kpex.sh" --pex-only --good || true ;;
    cc_bad)  "${ROOT}/run_kpex.sh" --pex-only --bad || true ;;
  esac
fi

case "$TAG" in
  cc_good|cc_bad|cc_demo)
    GDS="${ROOT}/kpex_demo.gds"
    [[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS} (run ./run_kpex.sh --gen-only)" >&2; exit 1; }
    ;;
  *)
    [[ -f "$GDS" ]] || [[ -f "${ROOT}/r_demo.gds" ]] || { echo "ERROR: missing GDS" >&2; exit 1; }
    [[ -f "$GDS" ]] || GDS="${ROOT}/r_demo.gds"
    ;;
esac

case "$TAG" in
  r_good) REPORT="${ROOT}/r_good.txt" ;;
  r_bad)  REPORT="${ROOT}/r_bad.txt" ;;
  c_good) REPORT="${ROOT}/c_good.txt" ;;
  c_bad)  REPORT="${ROOT}/c_bad.txt" ;;
  cc_good) REPORT="${ROOT}/cc_good.txt" ;;
  cc_bad)  REPORT="${ROOT}/cc_bad.txt" ;;
  *)      REPORT="" ;;
esac

if [[ -n "$REPORT" && -f "$REPORT" ]]; then
  echo "==> Last report (${REPORT}):"
  sed 's/^/    /' "$REPORT" || true
fi

echo "==> klayout ${GDS}"
exec klayout "$GDS"
