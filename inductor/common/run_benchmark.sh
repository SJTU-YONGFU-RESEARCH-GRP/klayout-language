#!/usr/bin/env bash
# Regenerate inductor/BENCHMARK.md from all inductor/<N> runs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 "$ROOT/inductor/common/update_benchmark.py" --root "$ROOT/inductor"
echo "Open: $ROOT/inductor/BENCHMARK.md"
