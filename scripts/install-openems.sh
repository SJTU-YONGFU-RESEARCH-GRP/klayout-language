#!/usr/bin/env bash
# Install openEMS + CSXCAD (with Python bindings) from source via the
# official openEMS-Project helper scripts:
#   https://docs.openems.de/en/stable/install/clone-build-install.html
#
# Usage:
#   ./install-openems.sh                 # clone, build Python bindings into ~/opt/openEMS
#   ./install-openems.sh --deps          # also install OS packages (needs sudo)
#   ./install-openems.sh --disable-gui   # headless / no AppCSXCAD
#   ./install-openems.sh --prefix ~/opt/openEMS
#   ./install-openems.sh --dry-run

set -euo pipefail

PREFIX="${HOME}/opt/openEMS"
SRC_DIR="${HOME}/src/openEMS-Project"
REPO_URL="https://github.com/thliebig/openEMS-Project.git"
BIN_LINK_DIR="${HOME}/.local/bin"
INSTALL_DEPS=0
DISABLE_GUI=0
WITH_CTB=0
DRY_RUN=0
NJOBS=""
UPDATE_ONLY=0
SKIP_CLONE=0
PYTHON_VENV_MODE="venv"   # auto|venv|site|disable
KEEP_SRC=1

usage() {
  cat <<'EOF'
Install openEMS + CSXCAD from source (official openEMS-Project).

Default: clone into ~/src/openEMS-Project, build into ~/opt/openEMS with
Python extensions (isolated venv under PREFIX/venv).

Options:
  -p, --prefix DIR       Install prefix (default: ~/opt/openEMS)
  -S, --src-dir DIR      Clone / source directory (default: ~/src/openEMS-Project)
  -b, --bin-dir DIR      Where to put openems-* helpers (default: ~/.local/bin)
  -d, --deps             Install OS build deps via scripts/install_deps.sh (sudo)
  -g, --disable-gui      Build without AppCSXCAD GUI (servers / headless)
  -c, --with-ctb         Enable Circuit Toolbox (Matlab/Octave)
  -j, --jobs N           Parallel compile jobs (default: nproc)
  -u, --update           Pull + rebuild existing clone (do not re-clone)
  --python-venv-mode M   auto|venv|site|disable (default: venv)
  -n, --dry-run          Print actions without cloning/building
  -h, --help             Show this help

Examples:
  ./install-openems.sh --deps --disable-gui
  ./install-openems.sh --prefix "$HOME/opt/openEMS" --jobs 4
  ./install-openems.sh --update

After install:
  source ~/opt/openEMS/venv/bin/activate   # or: openems-env
  python3 -c "from openEMS import openEMS; print('ok')"
  export PATH="$HOME/opt/openEMS/bin:$PATH"
EOF
}

log()  { printf '==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--prefix)
      [[ $# -ge 2 ]] || die "--prefix requires an argument"
      PREFIX="$2"
      shift 2
      ;;
    -S|--src-dir)
      [[ $# -ge 2 ]] || die "--src-dir requires an argument"
      SRC_DIR="$2"
      shift 2
      ;;
    -b|--bin-dir)
      [[ $# -ge 2 ]] || die "--bin-dir requires an argument"
      BIN_LINK_DIR="$2"
      shift 2
      ;;
    -d|--deps)
      INSTALL_DEPS=1
      shift
      ;;
    -g|--disable-gui)
      DISABLE_GUI=1
      shift
      ;;
    -c|--with-ctb)
      WITH_CTB=1
      shift
      ;;
    -j|--jobs)
      [[ $# -ge 2 ]] || die "--jobs requires an argument"
      NJOBS="$2"
      shift 2
      ;;
    -u|--update)
      UPDATE_ONLY=1
      SKIP_CLONE=1
      shift
      ;;
    --python-venv-mode)
      [[ $# -ge 2 ]] || die "--python-venv-mode requires an argument"
      PYTHON_VENV_MODE="$2"
      case "$PYTHON_VENV_MODE" in
        auto|venv|site|disable) ;;
        *) die "Invalid --python-venv-mode: $PYTHON_VENV_MODE (use auto|venv|site|disable)" ;;
      esac
      shift 2
      ;;
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1 (use --help)"
      ;;
  esac
done

detect_os() {
  if [[ ! -f /etc/os-release ]]; then
    die "Cannot detect OS (/etc/os-release missing)"
  fi
  # shellcheck disable=SC1091
  eval "$(
    . /etc/os-release
    printf 'OS_ID=%q\n' "${ID:-}"
    printf 'OS_ID_LIKE=%q\n' "${ID_LIKE:-}"
    printf 'OS_VERSION_ID=%q\n' "${VERSION_ID:-}"
    printf 'OS_PRETTY=%q\n' "${PRETTY_NAME:-}"
  )"
  ARCH="$(uname -m)"
  log "OS: ${OS_PRETTY:-$OS_ID $OS_VERSION_ID} ($ARCH)"
}

clone_or_update() {
  need_cmd git

  if [[ "$UPDATE_ONLY" -eq 1 ]]; then
    [[ -d "$SRC_DIR/.git" ]] || die "No existing clone at $SRC_DIR (omit --update for first install)"
    log "Updating existing clone: $SRC_DIR"
    if [[ "$DRY_RUN" -eq 0 ]]; then
      git -C "$SRC_DIR" pull --recurse-submodules
      git -C "$SRC_DIR" submodule update --init --recursive
    else
      run git -C "$SRC_DIR" pull --recurse-submodules
    fi
    return 0
  fi

  if [[ -d "$SRC_DIR/.git" ]]; then
    log "Source already present: $SRC_DIR (use --update to pull)"
    SKIP_CLONE=1
    return 0
  fi

  if [[ -e "$SRC_DIR" ]]; then
    die "Path exists but is not a git repo: $SRC_DIR"
  fi

  log "Cloning $REPO_URL -> $SRC_DIR"
  run mkdir -p "$(dirname "$SRC_DIR")"
  run git clone --recursive "$REPO_URL" "$SRC_DIR"
}

install_deps() {
  if [[ "$INSTALL_DEPS" -ne 1 ]]; then
    log "Skipping OS deps (pass --deps to install via install_deps.sh)"
    return 0
  fi

  local deps_script="${SRC_DIR}/scripts/install_deps.sh"
  local -a dep_args=(--auto --python)

  [[ "$DISABLE_GUI" -eq 1 ]] && dep_args+=(--disable-gui)
  [[ "$WITH_CTB" -eq 1 ]] && dep_args+=(--with-ctb)

  log "Installing OS build dependencies (may prompt for sudo)..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run "$deps_script" "${dep_args[@]}"
    return 0
  fi

  [[ -f "$deps_script" ]] || die "Missing $deps_script — clone failed?"

  if [[ "$(id -u)" -eq 0 ]]; then
    "$deps_script" "${dep_args[@]}"
  else
    need_cmd sudo
    sudo "$deps_script" "${dep_args[@]}"
  fi
}

build_openems() {
  need_cmd cmake
  need_cmd make
  need_cmd python3

  local -a build_args=("$PREFIX" --python "--python-venv-mode=${PYTHON_VENV_MODE}")
  [[ "$DISABLE_GUI" -eq 1 ]] && build_args+=(--disable-GUI)
  [[ "$WITH_CTB" -eq 1 ]] && build_args+=(--with-CTB)
  if [[ -n "$NJOBS" ]]; then
    build_args+=(--njobs "$NJOBS")
  fi

  log "Build prefix: $PREFIX"
  log "Python venv mode: $PYTHON_VENV_MODE"
  log "Running: ./update_openEMS.sh ${build_args[*]}"

  run mkdir -p "$PREFIX"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi

  (
    cd "$SRC_DIR"
    ./update_openEMS.sh "${build_args[@]}"
  )
}

write_helpers() {
  local env_helper="${BIN_LINK_DIR}/openems-env"
  local run_helper="${BIN_LINK_DIR}/openems-python"
  local bin_dir="${PREFIX}/bin"
  local venv_activate="${PREFIX}/venv/bin/activate"

  run mkdir -p "$BIN_LINK_DIR"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] write %s\n' "$env_helper"
    printf '[dry-run] write %s\n' "$run_helper"
    return 0
  fi

  cat >"$env_helper" <<EOF
#!/usr/bin/env bash
# Auto-generated by install-openems.sh — source this file:
#   source ${env_helper}
#   # or: . ${env_helper}
export PATH="${bin_dir}\${PATH:+:\$PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${PREFIX}/lib64\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
if [[ -f "${venv_activate}" ]]; then
  # shellcheck disable=SC1090
  source "${venv_activate}"
fi
EOF
  chmod 755 "$env_helper"

  cat >"$run_helper" <<EOF
#!/usr/bin/env bash
# Auto-generated by install-openems.sh — run Python with openEMS venv.
set -euo pipefail
export PATH="${bin_dir}\${PATH:+:\$PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${PREFIX}/lib64\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
if [[ -x "${PREFIX}/venv/bin/python" ]]; then
  exec "${PREFIX}/venv/bin/python" "\$@"
fi
exec python3 "\$@"
EOF
  chmod 755 "$run_helper"

  log "Helpers: ${env_helper}  ${run_helper}"
  if [[ ":${PATH}:" != *":${BIN_LINK_DIR}:"* ]]; then
    warn "Add to PATH: export PATH=\"${BIN_LINK_DIR}:\$PATH\""
  fi
}

verify_install() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Dry-run complete"
    return 0
  fi

  local py=""
  if [[ -x "${PREFIX}/venv/bin/python" ]]; then
    py="${PREFIX}/venv/bin/python"
  elif command -v python3 >/dev/null 2>&1; then
    py="python3"
    warn "No venv at ${PREFIX}/venv; verifying with system python3"
  else
    die "python3 not found for verification"
  fi

  export PATH="${PREFIX}/bin${PATH:+:$PATH}"
  export LD_LIBRARY_PATH="${PREFIX}/lib:${PREFIX}/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

  if [[ -x "${PREFIX}/bin/openEMS" ]]; then
    log "Binary: ${PREFIX}/bin/openEMS"
  else
    warn "openEMS binary not found at ${PREFIX}/bin/openEMS"
  fi

  log "Verifying Python import with: $py"
  if "$py" -c "from openEMS import openEMS; from CSXCAD import ContinuousStructure; print('openEMS+CSXCAD OK')"; then
    log "Python bindings OK"
  else
    die "Python import failed. Try: source ${BIN_LINK_DIR}/openems-env"
  fi
}

print_next_steps() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  cat <<EOF

Next steps:
  1. Activate the environment:
       source ${BIN_LINK_DIR}/openems-env
     (or: source ${PREFIX}/venv/bin/activate && export PATH="${PREFIX}/bin:\$PATH")
  2. Verify:
       python3 -c "from openEMS import openEMS; print('ok')"
  3. Run inductor EM (from repo root):
       ./inductor/common/run_openems.sh inductor/1

Docs: https://docs.openems.de/en/stable/install/clone-build-install.html
EOF
}

main() {
  detect_os
  log "Prefix: $PREFIX"
  log "Source: $SRC_DIR"

  clone_or_update
  install_deps
  build_openems
  write_helpers
  verify_install
  print_next_steps
  log "Done."
}

main "$@"
