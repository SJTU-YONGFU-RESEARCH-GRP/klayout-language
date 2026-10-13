#!/usr/bin/env bash
# Generate sky130A CC layouts and run KLayout-PEX (2.5D) coupling extraction.
#
# Usage:
#   ./run_kpex.sh              # generate + CC_GOOD/BAD PASS/FAIL
#   ./run_kpex.sh --good
#   ./run_kpex.sh --bad
#   ./run_kpex.sh --plate      # also extract C_PLATE (substrate)
#   ./run_kpex.sh --gen-only
#   ./run_kpex.sh --pex-only
#
# Requires: klayout, kpex (./scripts/install_kpex.sh), Python>=3.12

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/kpex_demo.gds"
GEN_RB="${ROOT}/generate_kpex_layout.rb"
OUT_DIR="${ROOT}/kpex_out"
export PATH="${HOME}/.local/bin:${PATH}"

# Coupling C_AB threshold (fF): close gap → PASS, far gap → FAIL
CC_LIMIT_FF="${CC_LIMIT_FF:-0.30}"
PDK="${PDK:-sky130A}"

MODE="all"
WHICH="both"
DO_PLATE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --good) WHICH="good" ;;
    --bad) WHICH="bad" ;;
    --plate) DO_PLATE=1 ;;
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

if ! command -v kpex >/dev/null 2>&1; then
  echo "ERROR: kpex not found on PATH" >&2
  echo "Install with: ${ROOT}/../scripts/install_kpex.sh" >&2
  exit 1
fi

echo "==> KLayout: $(klayout -v 2>/dev/null | head -1 || true)"
echo "==> kpex:    $(kpex --version 2>&1 | head -1 || true)"
echo "==> CC limit: ${CC_LIMIT_FF} fF  (PASS if C_AB >= limit)"

if [[ "$MODE" == "all" || "$MODE" == "gen" ]]; then
  echo "==> Generating ${GDS}"
  klayout -b -rd "output=${GDS}" -r "${GEN_RB}"
fi

if [[ "$MODE" == "gen" ]]; then
  exit 0
fi

# Parse C between nets A and B from kpex CSV (capacitance in fF).
parse_cab_ff() {
  local csv="$1"
  awk -F';' '
    BEGIN { IGNORECASE=1 }
    NR==1 { next }
    {
      n1=$2; n2=$3; c=$4+0
      if ((n1=="A" && n2=="B") || (n1=="B" && n2=="A")) { print c; found=1; exit }
    }
    END { if (!found) print "NA" }
  ' "$csv"
}

# Find newest *k25d_pex_netlist.csv under outdir for cell
find_csv() {
  local outdir="$1"
  find "$outdir" -name '*_k25d_pex_netlist.csv' -type f 2>/dev/null | head -1
}

run_cc() {
  local cell="$1"
  local tag="$2"
  local expect="$3"   # pass | fail
  local cell_out="${OUT_DIR}/${tag}"
  local report="${ROOT}/cc_${tag}.txt"
  local log="${ROOT}/cc_${tag}.log"
  local spice_copy="${ROOT}/cc_${tag}_extracted.cir"

  mkdir -p "$cell_out"
  echo "==> kpex/2.5D ${cell} → ${cell_out}"
  set +e
  kpex extract --pdk "${PDK}" --2.5D \
    --gds "${GDS}" \
    --cell "${cell}" \
    --out_dir "${cell_out}" \
    --tool_version_checks warn \
    --log_level warning \
    >"${log}" 2>&1
  local rc=$?
  set -e

  local csv
  csv="$(find_csv "$cell_out")"
  local cab="NA"
  if [[ -n "$csv" && -f "$csv" ]]; then
    cab="$(parse_cab_ff "$csv")"
    local spice
    spice="${csv%_k25d_pex_netlist.csv}_k25d_pex_netlist.spice"
    if [[ -f "$spice" ]]; then
      cp -f "$spice" "$spice_copy"
    fi
  fi

  local verdict="ERROR"
  local ok=1
  if [[ "$cab" == "NA" || -z "$cab" ]]; then
    verdict="ERROR (no C_AB in CSV; see ${log})"
    ok=1
  else
    # awk compare
    local ge
    ge="$(awk -v c="$cab" -v lim="$CC_LIMIT_FF" 'BEGIN{print (c+0 >= lim+0) ? 1 : 0}')"
    if [[ "$ge" -eq 1 ]]; then
      verdict="PASS"
    else
      verdict="FAIL"
    fi
    if [[ "$expect" == "pass" && "$verdict" == "PASS" ]]; then ok=0
    elif [[ "$expect" == "fail" && "$verdict" == "FAIL" ]]; then ok=0
    else ok=1
    fi
  fi

  {
    echo "KLayout-PEX 2.5D  cell=${cell}  pdk=${PDK}"
    echo "geometry: li1 parallel strips L=20um W=1um (see generate_kpex_layout.rb)"
    echo "C_AB = ${cab} fF"
    echo "limit = ${CC_LIMIT_FF} fF  (PASS if C_AB >= limit)"
    echo "result: ${verdict}  (expected ${expect})"
    if [[ -n "${csv:-}" && -f "${csv:-}" ]]; then
      echo ""
      echo "CSV:"
      cat "$csv"
    fi
  } >"$report"

  if [[ "$verdict" == "PASS" ]]; then
    echo "    RESULT: PASS  C_AB=${cab} fF  (>= ${CC_LIMIT_FF})"
  elif [[ "$verdict" == "FAIL" ]]; then
    echo "    RESULT: FAIL  C_AB=${cab} fF  (< ${CC_LIMIT_FF})"
  else
    echo "    RESULT: ${verdict}"
    if [[ $rc -ne 0 ]]; then
      echo "    kpex exit=${rc}; tail of log:"
      tail -20 "$log" | sed 's/^/    /'
    fi
  fi
  grep -E 'RESULT|C_AB|limit' "$report" | sed 's/^/    /' || true

  return "$ok"
}

run_plate() {
  local cell="C_PLATE"
  local tag="plate"
  local cell_out="${OUT_DIR}/${tag}"
  local report="${ROOT}/cc_${tag}.txt"
  local log="${ROOT}/cc_${tag}.log"

  mkdir -p "$cell_out"
  echo "==> kpex/2.5D ${cell} → ${cell_out}"
  set +e
  kpex extract --pdk "${PDK}" --2.5D \
    --gds "${GDS}" --cell "${cell}" --out_dir "${cell_out}" \
    --tool_version_checks warn --log_level warning \
    >"${log}" 2>&1
  set -e

  local csv
  csv="$(find_csv "$cell_out")"
  {
    echo "KLayout-PEX 2.5D  cell=${cell}  pdk=${PDK}"
    echo "(plate-to-substrate; no PASS/FAIL gate)"
    if [[ -n "$csv" && -f "$csv" ]]; then
      cat "$csv"
      local spice="${csv%_k25d_pex_netlist.csv}_k25d_pex_netlist.spice"
      [[ -f "$spice" ]] && cp -f "$spice" "${ROOT}/cc_${tag}_extracted.cir"
    else
      echo "ERROR: no CSV; see ${log}"
    fi
  } >"$report"
  echo "    wrote ${report}"
  cat "$report" | sed 's/^/    /'
}

FAILS=0
if [[ "$WHICH" == "both" || "$WHICH" == "good" ]]; then
  run_cc "CC_GOOD" "good" "pass" || FAILS=$((FAILS + 1))
fi
if [[ "$WHICH" == "both" || "$WHICH" == "bad" ]]; then
  run_cc "CC_BAD" "bad" "fail" || FAILS=$((FAILS + 1))
fi
if [[ "$DO_PLATE" -eq 1 ]]; then
  run_plate
fi

echo ""
if [[ "$FAILS" -eq 0 ]]; then
  echo "==> kpex demo OK (GOOD pass / BAD fail as expected)"
  exit 0
else
  echo "==> kpex demo: ${FAILS} unexpected result(s)" >&2
  exit 1
fi
