#!/usr/bin/env bash
# Usage: ./run_shorts.sh inductor/<N>
# Fails if parallel/bypass DC short paths are detected.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUN_REL="${1:?usage: $0 inductor/<N>}"
RUN="$ROOT/$RUN_REL"
[[ -d "$RUN" ]] || RUN="$RUN_REL"
CFG="$RUN/config.yaml"
GDS="$RUN/layout/inductor.gds"
OUT_DIR="$RUN/lvs"
mkdir -p "$OUT_DIR"

CELL=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG'))['cell'])")
PORTS=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG')).get('ports',2))")
LOG="$OUT_DIR/shorts.log"

klayout -b \
  -rd "input=$GDS" \
  -rd "cell=$CELL" \
  -rd "ports=$PORTS" \
  -rd "config=$CFG" \
  -rd "log=$LOG" \
  -r "$ROOT/inductor/common/check_shorts.rb" \
  | tee "$LOG"

grep -q "SHORTS PASS" "$LOG"
