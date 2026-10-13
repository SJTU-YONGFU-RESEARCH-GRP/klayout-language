#!/usr/bin/env bash
# Generate demo GDS and run M1/Contact DRC checks.
#
# Usage:
#   ./run_demo.sh              # regenerate GDS + run DRC
#   ./run_demo.sh --drc-only   # skip GDS generation
#   ./run_demo.sh --gen-only   # only write GDS

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/m1_contact_demo.gds"
LYRDB="${ROOT}/m1_contact.lyrdb"
GEN_RB="${ROOT}/generate_layout.rb"
DRC_RB="${ROOT}/m1_contact.drc"

MODE="all"
if [[ $# -gt 0 ]]; then
  case "$1" in
    --drc-only) MODE="drc" ;;
    --gen-only) MODE="gen" ;;
    -h|--help)
      sed -n '2,6p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
fi

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
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$LYRDB" <<'PY'
import sys, xml.etree.ElementTree as ET

path = sys.argv[1]
try:
    root = ET.parse(path).getroot()
except FileNotFoundError:
    print("No violations file written.")
    sys.exit(0)

items = root.findall(".//item")
print(f"Total violations: {len(items)}")
by_cat = {}
for it in items:
    cat = it.findtext("category") or "(unknown)"
    by_cat[cat] = by_cat.get(cat, 0) + 1
for cat in sorted(by_cat):
    print(f"  {cat}: {by_cat[cat]}")
PY
  fi
fi

echo "==> Done."
