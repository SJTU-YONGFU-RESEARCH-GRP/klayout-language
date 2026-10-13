#!/usr/bin/env bash
# Regenerate README screenshots under screenshots/.
#
# Usage:
#   ./scripts/run_capture_screenshots.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT}/scripts/capture_demo_screenshots.rb"

if ! command -v klayout >/dev/null 2>&1; then
  echo "ERROR: klayout not found on PATH" >&2
  exit 1
fi

# Refresh layouts / reports used by the capture script
"${ROOT}/drc/run_klayout_drc.sh" --gen-only
"${ROOT}/drc/run_klayout_drc.sh" --drc-only >/dev/null
"${ROOT}/lvs/run_lvs.sh" --gen-only
"${ROOT}/lvs/run_lvs.sh" --lvs-only >/dev/null
"${ROOT}/pex/run_pex.sh" --gen-only
"${ROOT}/pex/run_pex.sh" --pex-only >/dev/null

mkdir -p "${ROOT}/screenshots"

# Avoid Calibre/Qt library conflicts if MGC_HOME is in the environment
CLEAN_ENV=(env -u LD_LIBRARY_PATH)

if command -v xvfb-run >/dev/null 2>&1; then
  echo "==> Capturing via xvfb-run + klayout -z -x"
  "${CLEAN_ENV[@]}" xvfb-run -a -s '-screen 0 1920x1080x24' \
    klayout -z -x -r "${SCRIPT}"
else
  echo "==> Capturing via klayout -z -x (needs DISPLAY=${DISPLAY:-unset})"
  "${CLEAN_ENV[@]}" klayout -z -x -r "${SCRIPT}"
fi

echo "==> Screenshots:"
ls -la "${ROOT}/screenshots"/*.png
