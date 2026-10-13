#!/usr/bin/env bash
# Generate demo GDS (if needed) and run Calibre DRC on m1_contact_demo.gds.
#
# Usage:
#   ./run_calibre_drc.sh              # generate GDS + run Calibre DRC
#   ./run_calibre_drc.sh --drc-only   # skip GDS generation
#   ./run_calibre_drc.sh --gen-only   # only write GDS
#   ./run_calibre_drc.sh --view        # run DRC then open Calibre RVE
#
# Environment:
#   MGC_HOME   Mentor install root (default: search common paths)
#   CALIBRE    Calibre binary override (default: $MGC_HOME/bin/calibre)
#   CALDRV     Calibre DRV/RVE binary override (default: $MGC_HOME/bin/calibredrv)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/m1_contact_demo.gds"
RDB="${ROOT}/m1_contact.calibre.rdb"
REP="${ROOT}/m1_contact.calibre.rep"
LOG="${ROOT}/m1_contact.calibre.log"
RULES="${ROOT}/m1_contact.calibre.svrf"
GEN_RB="${ROOT}/generate_layout.rb"

MODE="all"
VIEW=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --drc-only) MODE="drc" ;;
    --gen-only) MODE="gen" ;;
    --view) VIEW=1 ;;
    -h|--help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

find_calibre() {
  if [[ -n "${CALIBRE:-}" && -x "${CALIBRE}" ]]; then
    printf '%s\n' "${CALIBRE}"
    return 0
  fi
  if command -v calibre >/dev/null 2>&1; then
    command -v calibre
    return 0
  fi
  local candidates=()
  [[ -n "${MGC_HOME:-}" ]] && candidates+=("${MGC_HOME}/bin/calibre")
  candidates+=(
    /opt/mentor/calibre/bin/calibre
    /usr/local/mentor/calibre/bin/calibre
    /opt/calibre/bin/calibre
  )
  local c
  for c in "${candidates[@]}"; do
    [[ -x "$c" ]] && { printf '%s\n' "$c"; return 0; }
  done
  return 1
}

find_calibredrv() {
  if [[ -n "${CALDRV:-}" && -x "${CALDRV}" ]]; then
    printf '%s\n' "${CALDRV}"
    return 0
  fi
  if command -v calibredrv >/dev/null 2>&1; then
    command -v calibredrv
    return 0
  fi
  local candidates=()
  [[ -n "${MGC_HOME:-}" ]] && candidates+=("${MGC_HOME}/bin/calibredrv")
  candidates+=(
    /opt/mentor/calibre/bin/calibredrv
    /usr/local/mentor/calibre/bin/calibredrv
    /opt/calibre/bin/calibredrv
  )
  local c
  for c in "${candidates[@]}"; do
    [[ -x "$c" ]] && { printf '%s\n' "$c"; return 0; }
  done
  return 1
}

generate_gds() {
  if ! command -v klayout >/dev/null 2>&1; then
    echo "ERROR: klayout not found (needed to generate ${GDS})" >&2
    echo "Install with: ${ROOT}/../scripts/install-klayout.sh --user" >&2
    exit 1
  fi
  echo "==> Generating ${GDS}"
  klayout -b -rd "output=${GDS}" -r "${GEN_RB}"
}

print_summary() {
  if [[ ! -f "$REP" ]]; then
    echo "WARN: summary report not found: ${REP}" >&2
    return 0
  fi
  echo "==> Summary: ${REP}"
  awk '
    /^--- RULECHECK RESULTS/ { show=1 }
    show && /^[A-Z0-9_]+/ {
      rule=$1
      for (i=1; i<=NF; i++) {
        if ($i ~ /^[0-9]+$/ && $(i+1) == "result" && $(i+2) ~ /^count:/i) {
          printf "  %s: %s\n", rule, $i
        }
      }
    }
    /^--- DRC SUMMARY/ { in_total=1; next }
    in_total && /TOTAL RULECHECK/ {
      print
      exit
    }
  ' "$REP" || true

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$REP" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8", errors="replace").read()
# Calibre summary lines like: "M1_MIN_WIDTH ........ TOTAL ........ 1"
counts = {}
for line in text.splitlines():
    m = re.match(r"^(M1_|CT_)\S+\s+\.+ TOTAL\s+\.+ (\d+)\s*$", line.strip())
    if m:
        counts[m.group(0).split()[0]] = int(m.group(2))
if counts:
    total = sum(counts.values())
    print(f"Total violations: {total}")
    for rule in sorted(counts):
        print(f"  {rule}: {counts[rule]}")
PY
  fi
}

if [[ "$MODE" == "all" || "$MODE" == "gen" ]]; then
  generate_gds
fi

if [[ "$MODE" == "all" || "$MODE" == "drc" ]]; then
  [[ -f "$GDS" ]] || { echo "ERROR: missing ${GDS}" >&2; exit 1; }
  [[ -f "$RULES" ]] || { echo "ERROR: missing ${RULES}" >&2; exit 1; }

  CALIBRE_BIN="$(find_calibre)" || {
    echo "ERROR: calibre not found." >&2
    echo "Set MGC_HOME or CALIBRE, e.g.:" >&2
    echo "  export MGC_HOME=/opt/mentor/calibre" >&2
    echo "  ./run_calibre_drc.sh" >&2
    exit 1
  }

  rm -f "$RDB" "$REP" "$LOG"
  echo "==> Calibre: $("$CALIBRE_BIN" -version 2>/dev/null | head -1 || echo "$CALIBRE_BIN")"
  echo "==> Running DRC on ${GDS}"
  echo "    Rules: ${RULES}"
  echo "    RDB:   ${RDB}"

  set +e
  "$CALIBRE_BIN" -drc -hier -turbo -nowait \
    -E "GDS=${GDS}" \
    -E "RDB=${RDB}" \
    -E "REP=${REP}" \
    "$RULES" 2>&1 | tee "$LOG"
  rc=${PIPESTATUS[0]}
  set -e

  if [[ "$rc" -ne 0 ]]; then
    echo "ERROR: calibre exited with status ${rc} (see ${LOG})" >&2
    exit "$rc"
  fi

  print_summary
  echo "==> Results: ${RDB}"
  echo "==> Log:     ${LOG}"

  if [[ "$VIEW" -eq 1 ]]; then
    CALDRV_BIN="$(find_calibredrv)" || {
      echo "WARN: calibredrv not found; open ${RDB} manually in Calibre RVE" >&2
      exit 0
    }
    echo "==> Opening Calibre RVE: ${GDS} + ${RDB}"
    exec "$CALDRV_BIN" "$GDS" -rve "$RDB"
  fi
fi

echo "==> Done."
