#!/usr/bin/env bash
# Usage: ./run_lvs.sh inductor/<N>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUN_REL="${1:?usage: $0 inductor/<N>}"
RUN="$ROOT/$RUN_REL"
[[ -d "$RUN" ]] || RUN="$RUN_REL"
CFG="$RUN/config.yaml"
GDS="$RUN/layout/inductor.gds"
LVS_DIR="$RUN/lvs"
mkdir -p "$LVS_DIR"

CELL=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG'))['cell'])")
PORTS=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG')).get('ports',2))")
CIR="$LVS_DIR/inductor.cir"
python3 "$ROOT/inductor/common/write_schematic.py" --config "$CFG" --out "$CIR"

LVSDB="$LVS_DIR/inductor.lvsdb"
LOG="$LVS_DIR/inductor.log"

klayout -b \
  -rd "input=$GDS" \
  -rd "cell=$CELL" \
  -rd "ports=$PORTS" \
  -rd "schematic=$CIR" \
  -rd "lvsdb=$LVSDB" \
  -r "$ROOT/inductor/common/inductor.lvs" \
  | tee "$LOG"

grep -q "LVS PASS" "$LOG"
