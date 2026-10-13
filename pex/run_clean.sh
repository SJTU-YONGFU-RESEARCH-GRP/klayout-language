#!/usr/bin/env bash
# Remove generated KLayout PEX outputs from this directory.
#
# Usage:
#   ./run_clean.sh           # clear reports / spice (keep GDS)
#   ./run_clean.sh --gds     # also remove GDS
#   ./run_clean.sh --dry-run

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
REMOVE_GDS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gds) REMOVE_GDS=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

remove_path() {
  local p="$1"
  [[ -e "$p" || -L "$p" ]] || return 0
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  would remove: $p"
  else
    rm -rf "$p"
    echo "  removed: $p"
  fi
}

echo "==> Cleaning generated PEX files in ${ROOT}"

shopt -s nullglob
for f in \
  "${ROOT}"/r_*.txt \
  "${ROOT}"/r_*_extracted.cir \
  "${ROOT}"/r_*.log \
  "${ROOT}"/c_*.txt \
  "${ROOT}"/c_*_extracted.cir \
  "${ROOT}"/c_*.log \
  "${ROOT}"/cc_*.txt \
  "${ROOT}"/cc_*_extracted.cir \
  "${ROOT}"/cc_*.log \
  "${ROOT}"/calibre_r_* \
  "${ROOT}"/calibre_c_* \
  "${ROOT}"/r_extract.txt \
  "${ROOT}"/r_extracted.cir \
  "${ROOT}"/c_extract.txt \
  "${ROOT}"/c_extracted.cir
do
  remove_path "$f"
done
shopt -u nullglob

remove_path "${ROOT}/kpex_out"
remove_path "${ROOT}/.calibre_pex_run"

if [[ "$REMOVE_GDS" -eq 1 ]]; then
  remove_path "${ROOT}/pex_demo.gds"
  remove_path "${ROOT}/r_demo.gds"
  remove_path "${ROOT}/kpex_demo.gds"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "==> Dry-run only; nothing deleted."
else
  echo "==> Done."
fi
