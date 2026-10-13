#!/usr/bin/env bash
# Usage: ./run_screenshot.sh inductor/<N>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUN_REL="${1:?usage: $0 inductor/<N>}"
RUN="$ROOT/$RUN_REL"
[[ -d "$RUN" ]] || RUN="$RUN_REL"
CFG="$RUN/config.yaml"
GDS="$RUN/layout/inductor.gds"
PNG="$RUN/layout/inductor.png"

[[ -f "$GDS" ]] || { echo "missing GDS: $GDS"; exit 1; }
CELL=$(python3 -c "import yaml; print(yaml.safe_load(open('$CFG'))['cell'])")

SCRIPT="$ROOT/inductor/common/capture_screenshot.rb"
CLEAN_ENV=(env -u LD_LIBRARY_PATH)

run_klayout() {
  "${CLEAN_ENV[@]}" "$@" -z -x \
    -rd "input=$GDS" \
    -rd "cell=$CELL" \
    -rd "output=$PNG" \
    -rd "width=1400" \
    -rd "height=1000" \
    -r "$SCRIPT"
}

if command -v xvfb-run >/dev/null 2>&1; then
  run_klayout xvfb-run -a -s '-screen 0 1920x1080x24' klayout
else
  run_klayout klayout
fi

echo "Screenshot: $PNG"
ls -la "$PNG"
