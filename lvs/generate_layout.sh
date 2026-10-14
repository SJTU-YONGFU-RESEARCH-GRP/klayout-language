#!/usr/bin/env bash
# Write nmos_demo.gds only (NMOS_GOOD / BAD / DEMO). Does not run LVS.
#
# Usage:
#   ./generate_layout.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS="${ROOT}/nmos_demo.gds"
GEN_RB="${ROOT}/generate_layout.rb"

if ! command -v klayout >/dev/null 2>&1; then
  echo "ERROR: klayout not found on PATH" >&2
  echo "Install with: ${ROOT}/../scripts/install-klayout.sh --user" >&2
  exit 1
fi

echo "==> KLayout: $(klayout -v 2>/dev/null | head -1 || true)"
echo "==> Generating ${GDS}"
klayout -b -rd "output=${GDS}" -r "${GEN_RB}"
echo "==> Done."
