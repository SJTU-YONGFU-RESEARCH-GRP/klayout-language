#!/usr/bin/env bash
# Run KLayout DRC on m1_contact_demo.gds (GOOD expect PASS, BAD expect FAIL).
# Does not generate GDS — run ./generate_layout.sh first.
#
# Usage:
#   ./run_klayout_drc.sh              # GOOD + BAD (+ DEMO report)
#   ./run_klayout_drc.sh --good       # GOOD cell only
#   ./run_klayout_drc.sh --bad        # BAD cell only
#   ./run_klayout_drc.sh --demo       # DEMO topcell only
#   ./run_klayout_drc.sh --drc-only   # same as default (compat alias)
#   ./run_klayout_drc.sh --gen-only   # alias → ./generate_layout.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/m1_contact_demo.gds"
DRC_RB="${ROOT}/m1_contact.drc"
GEN_SH="${ROOT}/generate_layout.sh"

WHICH="both"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --good) WHICH="good" ;;
    --bad) WHICH="bad" ;;
    --demo) WHICH="demo" ;;
    --drc-only) ;; # default is check-only
    --gen-only)
      exec "$GEN_SH"
      ;;
    -h|--help)
      sed -n '2,13p' "$0"
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

[[ -f "$GDS" ]] || {
  echo "ERROR: missing ${GDS}" >&2
  echo "Run:  ./generate_layout.sh" >&2
  exit 1
}

echo "==> KLayout: $(klayout -v 2>/dev/null | head -1 || true)"

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

echo "==> Done."
