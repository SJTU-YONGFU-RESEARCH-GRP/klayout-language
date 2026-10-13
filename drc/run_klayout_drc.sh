#!/usr/bin/env bash
# Generate M1/Contact demo GDS and run KLayout DRC (GOOD expect PASS, BAD expect FAIL).
#
# Usage:
#   ./run_klayout_drc.sh              # regenerate GDS + GOOD + BAD (+ DEMO report)
#   ./run_klayout_drc.sh --good       # GOOD cell only
#   ./run_klayout_drc.sh --bad        # BAD cell only
#   ./run_klayout_drc.sh --demo       # DEMO topcell only (both)
#   ./run_klayout_drc.sh --drc-only   # skip GDS generation
#   ./run_klayout_drc.sh --gen-only   # only write GDS

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/m1_contact_demo.gds"
GEN_RB="${ROOT}/generate_layout.rb"
DRC_RB="${ROOT}/m1_contact.drc"

MODE="all"
WHICH="both"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --good) WHICH="good" ;;
    --bad) WHICH="bad" ;;
    --demo) WHICH="demo" ;;
    --drc-only) MODE="drc" ;;
    --gen-only) MODE="gen" ;;
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
  echo "Install with: ${ROOT}/../scripts/install-klayout.sh --user" >&2
  exit 1
fi

echo "==> KLayout: $(klayout -v 2>/dev/null | head -1 || true)"

if [[ "$MODE" == "all" || "$MODE" == "gen" ]]; then
  echo "==> Generating ${GDS}"
  klayout -b -rd "output=${GDS}" -r "${GEN_RB}"
fi

# Returns 0=PASS, 1=FAIL, 2=error/unknown
run_one() {
  local cell="$1"
  local tag="$2"
  local lyrdb="${ROOT}/m1_contact_${tag}.lyrdb"
  local log="${ROOT}/m1_contact_${tag}.log"

  echo "==> DRC ${cell} → ${lyrdb}"
  klayout -b \
    -rd "input=${GDS}" \
    -rd "cell=${cell}" \
    -rd "report=${lyrdb}" \
    -r "${DRC_RB}" >"${log}" 2>&1 || true

  if grep -q "DRC PASS" "${log}"; then
    echo "    RESULT: PASS"
    grep -E '^(DRC |  )' "${log}" 2>/dev/null || true
    # Also print category counts when FAIL path not taken
    if command -v python3 >/dev/null 2>&1 && [[ -f "$lyrdb" ]]; then
      python3 - "$lyrdb" <<'PY' || true
import sys, xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
items = root.findall(".//item")
print(f"    violations: {len(items)}")
PY
    fi
    return 0
  fi
  if grep -q "DRC FAIL" "${log}"; then
    echo "    RESULT: FAIL (see ${lyrdb})"
    if command -v python3 >/dev/null 2>&1 && [[ -f "$lyrdb" ]]; then
      python3 - "$lyrdb" <<'PY'
import sys, xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
items = root.findall(".//item")
print(f"    Total violations: {len(items)}")
by_cat = {}
for it in items:
    cat = (it.findtext("category") or "(unknown)").strip("'")
    by_cat[cat] = by_cat.get(cat, 0) + 1
for cat in sorted(by_cat):
    print(f"      {cat}: {by_cat[cat]}")
PY
    fi
    return 1
  fi
  echo "    ERROR: no PASS/FAIL marker (see ${log})" >&2
  tail -30 "${log}" >&2 || true
  return 2
}

if [[ "$MODE" == "all" || "$MODE" == "drc" ]]; then
  [[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS} (run without --drc-only first)" >&2; exit 1; }

  fail=0

  if [[ "$WHICH" == "both" || "$WHICH" == "good" ]]; then
    rc=0
    run_one "M1_CT_GOOD" "good" || rc=$?
    if [[ "$rc" -ne 0 ]]; then
      echo "ERROR: expected GOOD cell to PASS" >&2
      fail=1
    fi
  fi

  if [[ "$WHICH" == "both" || "$WHICH" == "bad" ]]; then
    rc=0
    run_one "M1_CT_BAD" "bad" || rc=$?
    if [[ "$rc" -eq 0 ]]; then
      echo "ERROR: expected BAD cell to FAIL" >&2
      fail=1
    elif [[ "$rc" -eq 1 ]]; then
      echo "    (expected FAIL — demo OK)"
    else
      fail=1
    fi
  fi

  if [[ "$WHICH" == "demo" || "$WHICH" == "both" ]]; then
    # DEMO report for view_klayout_drc.sh / screenshot markers
    run_one "M1_CT_DRC_DEMO" "demo" || true
    if [[ -f "${ROOT}/m1_contact_demo.lyrdb" ]]; then
      cp -f "${ROOT}/m1_contact_demo.lyrdb" "${ROOT}/m1_contact.lyrdb"
    fi
  elif [[ "$WHICH" == "bad" && -f "${ROOT}/m1_contact_bad.lyrdb" ]]; then
    cp -f "${ROOT}/m1_contact_bad.lyrdb" "${ROOT}/m1_contact.lyrdb"
  fi

  if [[ "$fail" -ne 0 ]]; then
    exit 1
  fi
fi

echo "==> Done."
