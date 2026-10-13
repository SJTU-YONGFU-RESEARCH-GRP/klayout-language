#!/usr/bin/env bash
# Generate PEX demo GDS and run KLayout R + C extraction.
#
# Usage:
#   ./run_pex.sh              # generate + R GOOD/BAD + C GOOD/BAD
#   ./run_pex.sh --r          # resistance only
#   ./run_pex.sh --c          # capacitance only
#   ./run_pex.sh --good       # GOOD cells only
#   ./run_pex.sh --bad        # BAD cells only
#   ./run_pex.sh --gen-only
#   ./run_pex.sh --pex-only

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/pex_demo.gds"
GEN_RB="${ROOT}/generate_layout.rb"
PEX_R="${ROOT}/extract_r.rb"
PEX_C="${ROOT}/extract_c.lvs"

R_LIMIT="${R_LIMIT:-1.0}"
SHEET_R="${SHEET_R:-0.08}"
C_LIMIT="${C_LIMIT:-1e-15}"
AREA_CAP="${AREA_CAP:-1e-15}"

MODE="all"
WHICH="both"
KIND="both"   # r | c | both

while [[ $# -gt 0 ]]; do
  case "$1" in
    --good) WHICH="good" ;;
    --bad) WHICH="bad" ;;
    --r|--res|--resistance) KIND="r" ;;
    --c|--cap|--capacitance) KIND="c" ;;
    --gen-only) MODE="gen" ;;
    --pex-only) MODE="pex" ;;
    -h|--help)
      sed -n '2,14p' "$0"
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

run_r() {
  local cell="$1"
  local tag="$2"
  local report="${ROOT}/r_${tag}.txt"
  local spice="${ROOT}/r_${tag}_extracted.cir"
  local log="${ROOT}/r_${tag}.log"

  echo "==> PEX-R ${cell} → ${report}"
  klayout -b \
    -rd "input=${GDS}" \
    -rd "cell=${cell}" \
    -rd "report=${report}" \
    -rd "spice=${spice}" \
    -rd "sheet_r=${SHEET_R}" \
    -rd "r_limit=${R_LIMIT}" \
    -r "${PEX_R}" >"${log}" 2>&1 || true

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

run_c() {
  local cell="$1"
  local tag="$2"
  local report="${ROOT}/c_${tag}.txt"
  local spice="${ROOT}/c_${tag}_extracted.cir"
  local log="${ROOT}/c_${tag}.log"

  echo "==> PEX-C ${cell} → ${report}"
  klayout -b \
    -rd "input=${GDS}" \
    -rd "cell=${cell}" \
    -rd "report=${report}" \
    -rd "spice=${spice}" \
    -rd "area_cap=${AREA_CAP}" \
    -rd "c_limit=${C_LIMIT}" \
    -r "${PEX_C}" >"${log}" 2>&1 || true

  if grep -q "PEX PASS" "${log}"; then
    echo "    RESULT: PASS"
    grep -E 'extracted_C|PEX PASS|overlap' "${log}" | sed 's/^/    /' || true
    return 0
  fi
  if grep -q "PEX FAIL" "${log}"; then
    echo "    RESULT: FAIL"
    grep -E 'extracted_C|PEX FAIL|overlap' "${log}" | sed 's/^/    /' || true
    return 1
  fi
  echo "    ERROR: no PASS/FAIL marker (see ${log})" >&2
  tail -40 "${log}" >&2 || true
  return 2
}

if [[ "$MODE" == "all" || "$MODE" == "pex" ]]; then
  [[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS}" >&2; exit 1; }
  fail=0

  if [[ "$KIND" == "both" || "$KIND" == "r" ]]; then
    if [[ "$WHICH" == "both" || "$WHICH" == "good" ]]; then
      rc=0; run_r "R_GOOD" "good" || rc=$?
      [[ "$rc" -eq 0 ]] || { echo "ERROR: expected R_GOOD PASS" >&2; fail=1; }
    fi
    if [[ "$WHICH" == "both" || "$WHICH" == "bad" ]]; then
      rc=0; run_r "R_BAD" "bad" || rc=$?
      if [[ "$rc" -eq 1 ]]; then
        echo "    (expected R FAIL — demo OK)"
      else
        echo "ERROR: expected R_BAD FAIL" >&2; fail=1
      fi
    fi
  fi

  if [[ "$KIND" == "both" || "$KIND" == "c" ]]; then
    if [[ "$WHICH" == "both" || "$WHICH" == "good" ]]; then
      rc=0; run_c "C_GOOD" "good" || rc=$?
      [[ "$rc" -eq 0 ]] || { echo "ERROR: expected C_GOOD PASS" >&2; fail=1; }
    fi
    if [[ "$WHICH" == "both" || "$WHICH" == "bad" ]]; then
      rc=0; run_c "C_BAD" "bad" || rc=$?
      if [[ "$rc" -eq 1 ]]; then
        echo "    (expected C FAIL — demo OK)"
      else
        echo "ERROR: expected C_BAD FAIL" >&2; fail=1
      fi
    fi
  fi

  [[ "$fail" -eq 0 ]] || exit 1
fi

echo "==> Done."
