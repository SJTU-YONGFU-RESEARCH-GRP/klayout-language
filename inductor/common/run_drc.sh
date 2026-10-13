#!/usr/bin/env bash
# Usage: ./run_drc.sh inductor/<N>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUN_REL="${1:?usage: $0 inductor/<N>}"
RUN="$ROOT/$RUN_REL"
[[ -d "$RUN" ]] || RUN="$RUN_REL"
CFG="$RUN/config.yaml"
GDS="$RUN/layout/inductor.gds"
DRC_DIR="$RUN/drc"
mkdir -p "$DRC_DIR"

if [[ ! -f "$GDS" ]]; then
  echo "missing GDS: $GDS (run generate first)"
  exit 1
fi

CELL=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG'))['cell'])")
W=$(python3 -c "import yaml; c=yaml.safe_load(open('$CFG')); print(c.get('width_um',1.0))")
S=$(python3 -c "import yaml; c=yaml.safe_load(open('$CFG')); print(c.get('space_um',1.0))")
VIA=$(python3 -c "import yaml; c=yaml.safe_load(open('$CFG')); print(c.get('via_size_um',0.6))")
ENC=$(python3 -c "import yaml; c=yaml.safe_load(open('$CFG')); print(c.get('via_enc_um',0.2))")

REPORT="$DRC_DIR/inductor.lyrdb"
LOG="$DRC_DIR/inductor.log"

klayout -b \
  -rd "input=$GDS" \
  -rd "cell=$CELL" \
  -rd "report=$REPORT" \
  -rd "width_um=$W" \
  -rd "space_um=$S" \
  -rd "via_size_um=$VIA" \
  -rd "via_enc_um=$ENC" \
  -r "$ROOT/inductor/common/inductor.drc" \
  | tee "$LOG"

grep -q "DRC PASS" "$LOG"
