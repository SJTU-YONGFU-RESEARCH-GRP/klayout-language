#!/usr/bin/env bash
# Usage: ./run_openems.sh inductor/<N>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUN_REL="${1:?usage: $0 inductor/<N>}"
RUN="$ROOT/$RUN_REL"
[[ -d "$RUN" ]] || RUN="$RUN_REL"
CFG="$RUN/config.yaml"
GDS="$RUN/layout/inductor.gds"
SIM="$RUN/sim"
mkdir -p "$SIM"
LOG="$SIM/openems.log"

set +e
python3 "$ROOT/inductor/common/openems/run_sim.py" \
  --config "$CFG" \
  --gds "$GDS" \
  --sim-dir "$SIM" \
  --allow-analytic \
  2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
set -e

if [[ $rc -eq 0 ]]; then
  if grep -q SKIPPED_OPENEMS "$SIM/STATUS.txt" 2>/dev/null; then
    echo "openEMS SKIPPED (analytic placeholders written)"
  else
    echo "openEMS OK"
  fi
  exit 0
fi
echo "openEMS failed rc=$rc"
exit "$rc"
