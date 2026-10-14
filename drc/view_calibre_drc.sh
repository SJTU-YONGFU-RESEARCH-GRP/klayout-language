#!/usr/bin/env bash
# UI-friendly Calibre DRC: run rules against the layout via calibredrv Tcl.
# Layout path / top cell come from DESIGNrev — no GDS/RDB/REP env vars needed.
# Does not generate GDS — run ./generate_layout.sh first.
#
# Usage:
#   ./view_calibre_drc.sh                 # run DRC, open RVE
#   ./view_calibre_drc.sh --no-gui        # headless calibredrv -shell (no RVE window)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/m1_contact_demo.gds"
RDB="${ROOT}/m1_contact.calibre.rdb"
TCL="${ROOT}/run_drc_in_calibredrv.tcl"
ENV_FILE="${ROOT}/calibre.env"

GUI=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --drc-only) ;; # compat no-op (never gens)
    --no-gui) GUI=0 ;;
    -h|--help)
      sed -n '2,10p' "$0"
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
fi

[[ -f "$GDS" ]] || {
  echo "ERROR: missing ${GDS}" >&2
  echo "Run:  ./generate_layout.sh" >&2
  exit 1
}
[[ -f "$TCL" ]] || { echo "ERROR: missing ${TCL}" >&2; exit 1; }

CALDRV_BIN="${CALDRV:-}"
if [[ -z "$CALDRV_BIN" ]]; then
  if command -v calibredrv >/dev/null 2>&1; then
    CALDRV_BIN="$(command -v calibredrv)"
  elif [[ -n "${MGC_HOME:-}" && -x "${MGC_HOME}/bin/calibredrv" ]]; then
    CALDRV_BIN="${MGC_HOME}/bin/calibredrv"
  else
    echo "ERROR: calibredrv not found. Source calibre.env first." >&2
    exit 1
  fi
fi

echo "==> calibredrv: ${CALDRV_BIN}"
echo "==> Layout:    ${GDS}"
echo "==> Tcl:       ${TCL}"

# Auto-run DRC when launched via -s (interactive `source` skips this)
export DRV_AUTORUN=1
# calibredrv requires the first arg after -- to start with '-'
DRV_ARGS=(-- -gds "$GDS" -rdb "$RDB")
if [[ "$GUI" -eq 1 ]]; then
  "$CALDRV_BIN" -shell -s "$TCL" "${DRV_ARGS[@]}"
  echo "==> Opening RVE on ${RDB}"
  exec "$CALDRV_BIN" "$GDS" -rve -drc "$RDB"
else
  exec "$CALDRV_BIN" -shell -s "$TCL" "${DRV_ARGS[@]}"
fi
