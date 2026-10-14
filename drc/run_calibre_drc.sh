#!/usr/bin/env bash
# Run Calibre DRC on m1_contact_demo.gds.
# Does not generate GDS — run ./generate_layout.sh first.
#
# Usage:
#   ./run_calibre_drc.sh              # run Calibre DRC
#   ./run_calibre_drc.sh --drc-only   # same as default (compat alias)
#   ./run_calibre_drc.sh --gen-only   # alias → ./generate_layout.sh
#   ./run_calibre_drc.sh --view       # run DRC then open Calibre RVE
#   ./run_calibre_drc.sh --setup-help # print Calibre setup instructions
#
# ---------------------------------------------------------------------------
# Calibre setup (first time)
# ---------------------------------------------------------------------------
# Calibre is a licensed Mentor/Siemens tool — it is NOT installed by this repo.
#
# Option A — local env file (recommended):
#   cp calibre.env.example calibre.env
#   $EDITOR calibre.env          # set MGC_HOME to your install
#   ./run_calibre_drc.sh
#
# Option B — export in your shell:
#   export MGC_HOME=/opt/mentor/calibre
#   export PATH="$MGC_HOME/bin:$PATH"
#   ./run_calibre_drc.sh
#
# Option C — HPC module (if your site provides one):
#   module avail calibre          # find module name
#   module load calibre/2024.1    # example
#   ./run_calibre_drc.sh
#
# Option D — point directly at the binary:
#   export CALIBRE=/path/to/calibre/bin/calibre
#   ./run_calibre_drc.sh
#
# Verify setup:
#   $CALIBRE -version             # or: $MGC_HOME/bin/calibre -version
#
# View results after a run:
#   ./run_calibre_drc.sh --view   # opens calibredrv + RVE
#   ./view_calibre_drc.sh         # run DRC from calibredrv Tcl (uses open layout)
#
# Rule file (m1_contact.calibre.svrf) has NO layout/RDB paths — batch mode
# writes a tiny temp run deck that INCLUDEs the rules. UI mode gets GDS/cell
# from the open calibredrv layout (see run_drc_in_calibredrv.tcl).
#
# Environment (auto-loaded from calibre.env when present):
#   MGC_HOME / CALIBRE_HOME   Mentor install root
#   CALIBRE / CALDRV          binary overrides
#   MGLS_LICENSE_FILE         license file/server (site-specific)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/m1_contact_demo.gds"
RDB="${ROOT}/m1_contact.calibre.rdb"
REP="${ROOT}/m1_contact.calibre.rep"
LOG="${ROOT}/m1_contact.calibre.log"
RULES="${ROOT}/m1_contact.calibre.svrf"
GEN_SH="${ROOT}/generate_layout.sh"
ENV_FILE="${ROOT}/calibre.env"
ENV_EXAMPLE="${ROOT}/calibre.env.example"

VIEW=0
SETUP_HELP=0

load_calibre_env() {
  if [[ -f "$ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    echo "==> Loaded ${ENV_FILE}"
  fi
}

print_calibre_setup() {
  cat <<EOF
Calibre is not on PATH. Set it up using one of these options:

  Option A — local env file (recommended for this demo)
    cp ${ENV_EXAMPLE} ${ENV_FILE}
    \$EDITOR ${ENV_FILE}          # set MGC_HOME to your Calibre install
    ./run_calibre_drc.sh

  Option B — export in your shell session
    export MGC_HOME=/opt/mentor/calibre    # adjust path
    export PATH="\$MGC_HOME/bin:\$PATH"
    ./run_calibre_drc.sh

  Option C — environment module (HPC / shared CAD server)
    module avail calibre
    module load calibre                  # use your site's module name
    ./run_calibre_drc.sh

  Option D — explicit binary path
    export CALIBRE=/path/to/calibre/bin/calibre
    ./run_calibre_drc.sh

  License (if Calibre reports license errors)
    export MGLS_LICENSE_FILE=1717@your-license-server
    # ask your CAD/IT team for the correct value

  Verify before running DRC
    \$MGC_HOME/bin/calibre -version
    # or: calibre -version

  Find an existing install (run on a machine that has Calibre)
    which calibre
    ls /opt/mentor/*/bin/calibre 2>/dev/null
    ls /usr/local/mentor/*/bin/calibre 2>/dev/null

  After a successful run, view markers
    ./run_calibre_drc.sh --view
    calibredrv ${GDS} -rve ${RDB}

See also: ${ROOT}/README.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --drc-only) ;; # default is check-only
    --gen-only)
      exec "$GEN_SH"
      ;;
    --view) VIEW=1 ;;
    --setup-help) SETUP_HELP=1 ;;
    -h|--help)
      sed -n '2,48p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1 (try --setup-help)" >&2; exit 1 ;;
  esac
  shift
done

if [[ "$SETUP_HELP" -eq 1 ]]; then
  print_calibre_setup
  exit 0
fi

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

load_calibre_env

[[ -f "$GDS" ]] || {
  echo "ERROR: missing ${GDS}" >&2
  echo "Run:  ./generate_layout.sh" >&2
  exit 1
}
[[ -f "$RULES" ]] || { echo "ERROR: missing ${RULES}" >&2; exit 1; }

CALIBRE_BIN="$(find_calibre)" || {
  echo "ERROR: calibre not found." >&2
  echo >&2
  print_calibre_setup >&2
  exit 1
}

rm -f "$RDB" "$REP" "$LOG"
echo "==> Calibre: $("$CALIBRE_BIN" -version 2>/dev/null | head -1 || echo "$CALIBRE_BIN")"
echo "==> License: ${MGLS_LICENSE_FILE:-unset}"
echo "==> Running DRC on ${GDS}"
echo "    Rules: ${RULES}"
echo "    RDB:   ${RDB}"

# Rules file has no LAYOUT PATH. Write a tiny run deck that points at this
# GDS/RDB and INCLUDEs the shared rules (same pattern as calibredrv Tcl).
WORK="${ROOT}/.calibre_run"
mkdir -p "$WORK"
RUN_SVRF="${WORK}/run_batch.svrf"
PRIMARY="M1_CT_DRC_DEMO"
cat >"$RUN_SVRF" <<EOF
// Auto-generated by run_calibre_drc.sh — do not edit
LAYOUT PATH "${GDS}"
LAYOUT PRIMARY "${PRIMARY}"
LAYOUT SYSTEM GDSII
DRC SUMMARY REPORT "${REP}"
DRC RESULTS DATABASE "${RDB}" ASCII
INCLUDE "${RULES}"
EOF

set +e
(
  cd "$WORK"
  "$CALIBRE_BIN" -drc -hier -turbo -nowait "$RUN_SVRF"
) 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
set -e

rm -f "$WORK"/CalibreRRLog.* 2>/dev/null || true

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
  exec "$CALDRV_BIN" "$GDS" -rve -drc "$RDB"
fi

echo "==> Done."
