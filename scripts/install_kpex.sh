#!/usr/bin/env bash
# Install KLayout-PEX (kpex) into the user site-packages.
#
#   ./scripts/install_kpex.sh
#   ./scripts/install_kpex.sh --dry-run
#
# Requires Python >= 3.12 and klayout on PATH.
# Docs: https://iic-jku.github.io/klayout-pex-website/doc/doc.html

set -euo pipefail

DRY_RUN=0
PIP_INDEX=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1 ;;
    --index) PIP_INDEX="$2"; shift ;;
    -h|--help)
      sed -n '2,10p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

pick_python() {
  local c
  for c in python3.13 python3.12 python3; do
    if command -v "$c" >/dev/null 2>&1; then
      if "$c" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 12) else 1)'; then
        echo "$c"
        return 0
      fi
    fi
  done
  return 1
}

if ! PY="$(pick_python)"; then
  echo "ERROR: need Python >= 3.12 (kpex 0.6.x). Install python3.12+." >&2
  exit 1
fi

echo "==> Python: $($PY -V)"
if ! command -v klayout >/dev/null 2>&1; then
  echo "WARNING: klayout not on PATH — install with scripts/install-klayout.sh --user" >&2
else
  echo "==> KLayout: $(klayout -v 2>/dev/null | head -1 || true)"
fi

PIP_ARGS=(-m pip install --user --upgrade "klayout-pex>=0.6.6")
if [[ -n "$PIP_INDEX" ]]; then
  PIP_ARGS+=(-i "$PIP_INDEX")
fi

echo "==> ${PY} ${PIP_ARGS[*]}"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "==> Dry-run only."
  exit 0
fi

"$PY" "${PIP_ARGS[@]}"

# Ensure ~/.local/bin is on PATH for this check
export PATH="${HOME}/.local/bin:${PATH}"
if ! command -v kpex >/dev/null 2>&1; then
  echo "ERROR: kpex not found after install. Add ~/.local/bin to PATH." >&2
  exit 1
fi

echo "==> kpex $($PY -c 'from klayout_pex.version import __version__; print(__version__)' 2>/dev/null || kpex --version 2>&1 | head -1)"
echo "==> Done. Try:  cd pex && ./run_kpex.sh"
echo "    Note: MAGIC engine needs magic >= 8.3.679; 2.5D engine needs only KLayout."
