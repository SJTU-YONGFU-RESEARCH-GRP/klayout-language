#!/usr/bin/env bash
# Generate NMOS demo GDS and run KLayout LVS (GOOD expect PASS, BAD expect FAIL).
#
# Usage:
#   ./run_lvs.sh              # generate GDS + GOOD + BAD
#   ./run_lvs.sh --good       # GOOD cell only
#   ./run_lvs.sh --bad        # BAD cell only
#   ./run_lvs.sh --gen-only   # only write GDS
#   ./run_lvs.sh --lvs-only   # skip GDS generation

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/nmos_demo.gds"
GEN_RB="${ROOT}/generate_layout.rb"
LVS_RB="${ROOT}/transistor.lvs"
CIR="${ROOT}/nmos.cir"

MODE="all"
WHICH="both"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --good) WHICH="good" ;;
    --bad) WHICH="bad" ;;
    --gen-only) MODE="gen" ;;
    --lvs-only) MODE="lvs" ;;
    -h|--help)
      sed -n '2,10p' "$0"
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
  local lvsdb="${ROOT}/nmos_${tag}.lvsdb"
  local l2ndb="${ROOT}/nmos_${tag}.l2ndb"
  local extracted="${ROOT}/nmos_${tag}_extracted.cir"
  local log="${ROOT}/nmos_${tag}.log"

  echo "==> LVS ${cell} → ${lvsdb}"
  # Do not toggle set -e here — a non-zero return would abort the caller.
  klayout -b \
    -rd "input=${GDS}" \
    -rd "cell=${cell}" \
    -rd "schematic=${CIR}" \
    -rd "lvsdb=${lvsdb}" \
    -rd "l2ndb=${l2ndb}" \
    -rd "extracted=${extracted}" \
    -r "${LVS_RB}" >"${log}" 2>&1 || true

  if grep -q "LVS PASS" "${log}"; then
    echo "    RESULT: PASS"
    return 0
  fi
  if grep -q "LVS FAIL" "${log}"; then
    echo "    RESULT: FAIL (see ${lvsdb})"
    return 1
  fi
  echo "    ERROR: no PASS/FAIL marker (see ${log})" >&2
  tail -20 "${log}" >&2 || true
  return 2
}

if [[ "$MODE" == "all" || "$MODE" == "lvs" ]]; then
  [[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS}" >&2; exit 1; }
  [[ -f "$CIR" ]] || { echo "ERROR: missing ${CIR}" >&2; exit 1; }

  fail=0

  if [[ "$WHICH" == "both" || "$WHICH" == "good" ]]; then
    rc=0
    run_one "NMOS_GOOD" "good" || rc=$?
    if [[ "$rc" -ne 0 ]]; then
      echo "ERROR: expected GOOD cell to PASS" >&2
      fail=1
    fi
  fi

  if [[ "$WHICH" == "both" || "$WHICH" == "bad" ]]; then
    rc=0
    run_one "NMOS_BAD" "bad" || rc=$?
    if [[ "$rc" -eq 1 ]]; then
      echo "    (expected FAIL — demo OK)"
    elif [[ "$rc" -eq 0 ]]; then
      echo "ERROR: expected BAD cell to FAIL LVS" >&2
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
