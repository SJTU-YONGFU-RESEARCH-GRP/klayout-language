#!/usr/bin/env bash
# Generate M1/Contact demo GDS and run KLayout DRC.
#
# Usage:
#   ./run_klayout_drc.sh              # regenerate GDS + run DRC
#   ./run_klayout_drc.sh --drc-only   # skip GDS generation
#   ./run_klayout_drc.sh --gen-only   # only write GDS

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/m1_contact_demo.gds"
LYRDB="${ROOT}/m1_contact.lyrdb"
GEN_RB="${ROOT}/generate_layout.rb"
DRC_RB="${ROOT}/m1_contact.drc"

MODE="all"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --drc-only) MODE="drc" ;;
    --gen-only) MODE="gen" ;;
    -h|--help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

if ! command -v klayout >/dev/null 2>&1; then
  echo "ERROR: klayout not found on PATH" >&2
  echo "Install with: ${ROOT}/../scripts/install-klayout.sh --user" >&2
  exit 1
fi

echo "==> KLayout: $(klayout -v 2>/dev/null | head -1 || true)"

if [[ "$MODE" == "all" || "$MODE" == "gen" ]]; then
  echo "==> Generating ${GDS}"
  klayout -b -rd "output=${GDS}" -r "${GEN_RB}"
fi

if [[ "$MODE" == "all" || "$MODE" == "drc" ]]; then
  [[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS} (run without --drc-only first)" >&2; exit 1; }
  rm -f "$LYRDB"
  echo "==> Running DRC on ${GDS}"
  klayout -b \
    -rd "input=${GDS}" \
    -rd "report=${LYRDB}" \
    -r "${DRC_RB}"
  echo "==> Report: ${LYRDB}"
  if command -v python3 >/dev/null 2>&1 && [[ -f "$LYRDB" ]]; then
    python3 - "$LYRDB" <<'PY'
import sys, xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
items = root.findall(".//item")
print(f"Total violations: {len(items)}")
by_cat = {}
for it in items:
    cat = (it.findtext("category") or "(unknown)").strip("'")
    by_cat[cat] = by_cat.get(cat, 0) + 1
for cat in sorted(by_cat):
    print(f"  {cat}: {by_cat[cat]}")
PY
  fi
fi

echo "==> Done."
