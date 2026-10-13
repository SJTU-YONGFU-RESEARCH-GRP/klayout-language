#!/usr/bin/env bash
# Physical EM for inductor/<N>: prefer openEMS FDTD; else GDS PEEC + plots.
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
GEOM="$SIM/geometry.json"

CELL=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG'))['cell'])")
W=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG')).get('width_um',1.0))")
NAME=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG')).get('name','inductor'))")

{
  echo "== extract geometry =="
  klayout -b \
    -rd "input=$GDS" \
    -rd "cell=$CELL" \
    -rd "output=$GEOM" \
    -rd "width_um=$W" \
    -r "$ROOT/inductor/common/openems/extract_geometry.rb"

  echo "== try openEMS FDTD =="
  set +e
  python3 "$ROOT/inductor/common/openems/run_sim.py" \
    --config "$CFG" \
    --gds "$GDS" \
    --sim-dir "$SIM"
  rc=$?
  set -e

  if [[ $rc -ne 0 ]] || grep -q 'SKIPPED_OPENEMS\|not available\|OPENEMS_RAN_PLACEHOLDER' "$SIM/STATUS.txt" 2>/dev/null; then
    echo "== PEEC geometry EM (physical, from GDS centerline) =="
    python3 "$ROOT/inductor/common/openems/em_peec.py" \
      --config "$CFG" \
      --geometry "$GEOM" \
      --sim-dir "$SIM"
  fi

  echo "== plot =="
  python3 "$ROOT/inductor/common/openems/plot_results.py" \
    --sim-dir "$SIM" \
    --title "$NAME ($CELL)"

  echo "== done =="
  cat "$SIM/STATUS.txt"
  ls -la "$SIM/performance.png" "$SIM/lq.csv" "$SIM/sparams.csv" "$SIM/summary.json"
} 2>&1 | tee "$LOG"
