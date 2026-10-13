#!/usr/bin/env bash
# Remove generated Calibre / KLayout DRC outputs from this demo directory.
#
# Usage:
#   ./run_clean.sh           # clear reports, logs, run dirs (keep GDS)
#   ./run_clean.sh --gds     # also remove m1_contact_demo.gds
#   ./run_clean.sh --dry-run # show what would be deleted

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
  if [[ ! -e "$p" && ! -L "$p" ]]; then
    return 0
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  would remove: $p"
  else
    rm -rf "$p"
    echo "  removed: $p"
  fi
}

echo "==> Cleaning generated files in ${ROOT}"

# KLayout
remove_path "${ROOT}/m1_contact.lyrdb"

# Calibre results / logs
remove_path "${ROOT}/m1_contact.calibre.rdb"
remove_path "${ROOT}/m1_contact.calibre.rep"
remove_path "${ROOT}/m1_contact.calibre.log"

# Calibre working dirs / leftovers
remove_path "${ROOT}/.calibre_run"
remove_path "${ROOT}/calibredrc"
remove_path "${ROOT}/out.rdb"
remove_path "${ROOT}/out.rep"

# Occasional Calibre controller logs if a run was started from this directory
shopt -s nullglob
for f in "${ROOT}"/CalibreRRLog.*; do
  remove_path "$f"
done
shopt -u nullglob

if [[ "$REMOVE_GDS" -eq 1 ]]; then
  remove_path "${ROOT}/m1_contact_demo.gds"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "==> Dry-run only; nothing deleted."
else
  echo "==> Done."
fi
