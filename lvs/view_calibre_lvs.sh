#!/usr/bin/env bash
# Open Calibre LVS results for the NMOS demo (report text and optional RVE).
#
# Usage:
#   ./view_calibre_lvs.sh              # show GOOD summary + open RVE if available
#   ./view_calibre_lvs.sh --bad        # BAD cell
#   ./view_calibre_lvs.sh --no-gui     # print report only (no calibredrv)
#   ./view_calibre_lvs.sh --run        # run Calibre LVS first, then view
#
# Needs calibre.env (same as run_calibre_lvs.sh). Reports from a prior
# ./run_calibre_lvs.sh live as calibre_lvs_{good,bad}.{txt,rep}.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/nmos_demo.gds"
ENV_FILE="${ROOT}/calibre.env"
ENV_DRC="${ROOT}/../drc/calibre.env"

TAG="good"
GUI=1
RUN_FIRST=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bad) TAG="bad" ;;
    --good) TAG="good" ;;
    --no-gui) GUI=0 ;;
    --run) RUN_FIRST=1 ;;
    -h|--help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  echo "==> Loaded ${ENV_FILE}"
elif [[ -f "$ENV_DRC" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_DRC"
  echo "==> Loaded ${ENV_DRC}"
fi

if [[ "$RUN_FIRST" -eq 1 ]]; then
  "${ROOT}/run_calibre_lvs.sh" --lvs-only "--${TAG}"
fi

TXT="${ROOT}/calibre_lvs_${TAG}.txt"
REP="${ROOT}/calibre_lvs_${TAG}.rep"
SP="${ROOT}/calibre_lvs_${TAG}.sp"

[[ -f "$TXT" || -f "$REP" ]] || {
  echo "ERROR: missing Calibre LVS results for ${TAG}." >&2
  echo "Run:  ./run_calibre_lvs.sh --${TAG}" >&2
  exit 1
}

echo "==> Calibre LVS ${TAG}"
if [[ -f "$TXT" ]]; then
  echo "---- ${TXT} ----"
  cat "$TXT"
fi
if [[ -f "$SP" ]]; then
  echo ""
  echo "---- ${SP} ----"
  cat "$SP"
fi

if [[ "$GUI" -eq 0 ]]; then
  exit 0
fi

[[ -f "$GDS" ]] || { echo "WARN: missing ${GDS}; skip RVE" >&2; exit 0; }
[[ -f "$REP" ]] || { echo "WARN: missing ${REP}; skip RVE" >&2; exit 0; }

CALDRV_BIN="${CALDRV:-}"
if [[ -z "$CALDRV_BIN" ]]; then
  if command -v calibredrv >/dev/null 2>&1; then
    CALDRV_BIN="$(command -v calibredrv)"
  elif [[ -n "${MGC_HOME:-}" && -x "${MGC_HOME}/bin/calibredrv" ]]; then
    CALDRV_BIN="${MGC_HOME}/bin/calibredrv"
  else
    echo "WARN: calibredrv not found; reports printed above" >&2
    exit 0
  fi
fi

echo ""
echo "==> Opening Calibre RVE: ${GDS} + ${REP}"
exec "$CALDRV_BIN" "$GDS" -rve -lvs "$REP"
