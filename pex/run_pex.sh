#!/usr/bin/env bash
# Generate M1 resistor demo GDS and run KLayout PEX (GOOD low R / BAD high R).
#
# Usage:
#   ./run_pex.sh              # generate GDS + GOOD + BAD
#   ./run_pex.sh --good       # GOOD cell only (expect PASS)
#   ./run_pex.sh --bad        # BAD cell only (expect FAIL)
#   ./run_pex.sh --gen-only   # only write GDS
#   ./run_pex.sh --pex-only   # skip GDS generation

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/r_demo.gds"
GEN_RB="${ROOT}/generate_layout.rb"
PEX_RB="${ROOT}/extract_r.rb"

# PASS if extracted R < limit (ohm). GOOD ~0.16, BAD ~6.4 @ 0.08 ohm/sq.
R_LIMIT="${R_LIMIT:-1.0}"
SHEET_R="${SHEET_R:-0.08}"

MODE="all"
WHICH="both"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --good) WHICH="good" ;;
    --bad) WHICH="bad" ;;
    --gen-only) MODE="gen" ;;
    --pex-only) MODE="pex" ;;
    -h|--help)
      sed -n '2,11p' "$0"
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

# Returns 0=PASS, 1=FAIL, 2=error
run_one() {
  local cell="$1"
  local tag="$2"
  local report="${ROOT}/r_${tag}.txt"
  local spice="${ROOT}/r_${tag}_extracted.cir"
  local log="${ROOT}/r_${tag}.log"

  echo "==> PEX ${cell} → ${report}"
  klayout -b \
    -rd "input=${GDS}" \
    -rd "cell=${cell}" \
    -rd "report=${report}" \
    -rd "spice=${spice}" \
    -rd "sheet_r=${SHEET_R}" \
    -rd "r_limit=${R_LIMIT}" \
    -r "${PEX_RB}" >"${log}" 2>&1 || true

  if grep -q "PEX PASS" "${log}"; then
    echo "    RESULT: PASS"
    grep -E 'extracted_R|PEX PASS|geometry' "${log}" | sed 's/^/    /' || true
    return 0
  fi
  if grep -q "PEX FAIL" "${log}"; then
    echo "    RESULT: FAIL"
    grep -E 'extracted_R|PEX FAIL|geometry' "${log}" | sed 's/^/    /' || true
    return 1
  fi
  echo "    ERROR: no PASS/FAIL marker (see ${log})" >&2
  tail -30 "${log}" >&2 || true
  return 2
}

if [[ "$MODE" == "all" || "$MODE" == "pex" ]]; then
  [[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS} (run without --pex-only first)" >&2; exit 1; }

  fail=0

  if [[ "$WHICH" == "both" || "$WHICH" == "good" ]]; then
    rc=0
    run_one "R_GOOD" "good" || rc=$?
    if [[ "$rc" -ne 0 ]]; then
      echo "ERROR: expected GOOD cell to PASS (R < ${R_LIMIT})" >&2
      fail=1
    fi
  fi

  if [[ "$WHICH" == "both" || "$WHICH" == "bad" ]]; then
    rc=0
    run_one "R_BAD" "bad" || rc=$?
    if [[ "$rc" -eq 1 ]]; then
      echo "    (expected FAIL — demo OK)"
    elif [[ "$rc" -eq 0 ]]; then
      echo "ERROR: expected BAD cell to FAIL (R >= ${R_LIMIT})" >&2
      fail=1
    else
      fail=1
    fi
  fi

  if [[ "$fail" -ne 0 ]]; then
    exit 1
  fi
fi

echo "==> Done."
