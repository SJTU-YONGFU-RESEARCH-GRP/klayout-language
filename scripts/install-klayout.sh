#!/usr/bin/env bash
# Install KLayout from official binary packages:
#   https://www.klayout.de/build.html
#
# Usage:
#   ./install-klayout.sh                 # user install if not root
#   ./install-klayout.sh --user          # extract into ~/opt/klayout (no sudo)
#   sudo ./install-klayout.sh --system   # system-wide dnf/apt install
#   ./install-klayout.sh --version 0.30.12
#   ./install-klayout.sh --master
#   ./install-klayout.sh --dry-run

set -euo pipefail

KLAYOUT_VERSION="0.30.12"
USE_MASTER=0
DRY_RUN=0
DOWNLOAD_DIR="${TMPDIR:-/tmp}/klayout-install-$$"
KEEP_PKG=0
INSTALL_MODE=""   # user | system (auto if empty)
PREFIX="${HOME}/opt/klayout"
BIN_LINK_DIR="${HOME}/.local/bin"

BASE_URL="https://www.klayout.org/downloads"

usage() {
  cat <<'EOF'
Install KLayout from official packages.

Default: --user when not root, --system when root.

Options:
  -u, --user          Install into PREFIX without root (RPM/DEB extract)
  -s, --system        System-wide install via dnf/yum/apt (needs root)
  -p, --prefix DIR    User install prefix (default: ~/opt/klayout)
  -b, --bin-dir DIR   Where to put klayout launcher (default: ~/.local/bin)
  -v, --version VER   Stable version (default: 0.30.12)
  -m, --master        Install master/nightly build instead of stable
  -d, --dir DIR       Download directory (default: temp dir)
  -k, --keep          Keep downloaded package after install
  -n, --dry-run       Print actions without downloading/installing
  -h, --help          Show this help

Examples:
  ./install-klayout.sh --user
  ./install-klayout.sh --user --prefix "$HOME/apps/klayout"
  sudo ./install-klayout.sh --system
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
    -u|--user)
      INSTALL_MODE="user"
      shift
      ;;
    -s|--system)
      INSTALL_MODE="system"
      shift
      ;;
    -p|--prefix)
      [[ $# -ge 2 ]] || die "--prefix requires an argument"
      PREFIX="$2"
      INSTALL_MODE="${INSTALL_MODE:-user}"
      shift 2
      ;;
    -b|--bin-dir)
      [[ $# -ge 2 ]] || die "--bin-dir requires an argument"
      BIN_LINK_DIR="$2"
      shift 2
      ;;
    -v|--version)
      [[ $# -ge 2 ]] || die "--version requires an argument"
      KLAYOUT_VERSION="$2"
      shift 2
      ;;
    -m|--master)
      USE_MASTER=1
      shift
      ;;
    -d|--dir)
      [[ $# -ge 2 ]] || die "--dir requires an argument"
      DOWNLOAD_DIR="$2"
      shift 2
      ;;
    -k|--keep)
      KEEP_PKG=1
      shift
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
  # Read in a subshell so OS VERSION= does not clobber KLAYOUT_VERSION.
  # shellcheck disable=SC1091
  eval "$(
    . /etc/os-release
    printf 'OS_ID=%q\n' "${ID:-}"
    printf 'OS_ID_LIKE=%q\n' "${ID_LIKE:-}"
    printf 'OS_VERSION_ID=%q\n' "${VERSION_ID:-}"
    printf 'OS_PRETTY=%q\n' "${PRETTY_NAME:-}"
  )"
  OS_MAJOR="${OS_VERSION_ID%%.*}"
  ARCH="$(uname -m)"

  case "$ARCH" in
    x86_64|amd64) ;;
    *) die "Unsupported architecture: $ARCH (official packages are x86_64)" ;;
  esac
}

resolve_mode() {
  if [[ -z "$INSTALL_MODE" ]]; then
    if [[ "$(id -u)" -eq 0 ]]; then
      INSTALL_MODE="system"
    else
      INSTALL_MODE="user"
      log "No root privileges; using user install (--user). Use --system with sudo for system-wide."
    fi
  fi

  if [[ "$INSTALL_MODE" == "system" && "$(id -u)" -ne 0 && "$DRY_RUN" -eq 0 ]]; then
    die "System install needs root. Use: sudo $0 --system
Or install without sudo: $0 --user"
  fi
}

resolve_package() {
  # Sets: PKG_URL PKG_NAME PKG_KIND (rpm|deb) PKG_LABEL
  local family=""

  if [[ "$OS_ID" == "rhel" || "$OS_ID" == "rocky" || "$OS_ID" == "almalinux" || "$OS_ID" == "centos" ]] \
     || [[ "$OS_ID_LIKE" == *"rhel"* || "$OS_ID_LIKE" == *"fedora"* || "$OS_ID_LIKE" == *"centos"* ]]; then
    family="el"
  elif [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" || "$OS_ID_LIKE" == *"debian"* ]]; then
    family="debian"
  else
    die "Unsupported OS: ${OS_PRETTY:-$OS_ID}. Supported: RHEL/Rocky/Alma/CentOS, Ubuntu/Debian."
  fi

  if [[ "$family" == "el" ]]; then
    PKG_KIND="rpm"
    case "$OS_MAJOR" in
      9)
        if [[ "$USE_MASTER" -eq 1 ]]; then
          PKG_NAME="klayout-master-0.x86_64.rpm"
          PKG_URL="${BASE_URL}/master/rockylinux9/${PKG_NAME}"
          PKG_LABEL="Rocky Linux 9 master"
        else
          PKG_NAME="klayout-${KLAYOUT_VERSION}-0.x86_64.rpm"
          PKG_URL="${BASE_URL}/RockyLinux_9/${PKG_NAME}"
          PKG_LABEL="Rocky Linux 9 ${KLAYOUT_VERSION}"
        fi
        ;;
      8)
        if [[ "$USE_MASTER" -eq 1 ]]; then
          PKG_NAME="klayout-master-0.x86_64.rpm"
          PKG_URL="${BASE_URL}/master/centos8/${PKG_NAME}"
          PKG_LABEL="CentOS 8 master"
        else
          PKG_NAME="klayout-${KLAYOUT_VERSION}-0.x86_64.rpm"
          PKG_URL="${BASE_URL}/CentOS_8/${PKG_NAME}"
          PKG_LABEL="CentOS 8 ${KLAYOUT_VERSION}"
        fi
        ;;
      7)
        if [[ "$USE_MASTER" -eq 1 ]]; then
          PKG_NAME="klayout-master-0.x86_64.rpm"
          PKG_URL="${BASE_URL}/master/centos7/${PKG_NAME}"
          PKG_LABEL="CentOS 7 master"
        else
          PKG_NAME="klayout-${KLAYOUT_VERSION}-0.x86_64.rpm"
          PKG_URL="${BASE_URL}/CentOS_7/${PKG_NAME}"
          PKG_LABEL="CentOS 7 ${KLAYOUT_VERSION}"
        fi
        ;;
      *)
        die "Unsupported EL major version: ${OS_MAJOR} (supported: 7, 8, 9)"
        ;;
    esac
  else
    PKG_KIND="deb"
    local ubuntu_codename=""
    case "$OS_MAJOR" in
      24|26) ubuntu_codename="ubuntu${OS_MAJOR}" ;;
      22) ubuntu_codename="ubuntu22" ;;
      20) ubuntu_codename="ubuntu20" ;;
      18) ubuntu_codename="ubuntu18" ;;
      *)
        if [[ "$OS_ID" == "ubuntu" ]]; then
          die "Unsupported Ubuntu version: ${OS_VERSION_ID} (supported: 18/20/22/24/26)"
        fi
        warn "Debian detected (${OS_VERSION_ID}); using Ubuntu 22 package"
        ubuntu_codename="ubuntu22"
        OS_MAJOR="22"
        ;;
    esac

    if [[ "$USE_MASTER" -eq 1 ]]; then
      PKG_NAME="klayout_master-1_amd64.deb"
      PKG_URL="${BASE_URL}/master/${ubuntu_codename}/${PKG_NAME}"
      PKG_LABEL="${ubuntu_codename} master"
    else
      local folder
      case "$OS_MAJOR" in
        26) folder="Ubuntu_26.04" ;;
        24) folder="Ubuntu_24.04" ;;
        22) folder="Ubuntu_22.04" ;;
        20) folder="Ubuntu_20.04" ;;
        18) folder="Ubuntu_18.04" ;;
        *) die "Internal error: unhandled Ubuntu major ${OS_MAJOR}" ;;
      esac
      PKG_NAME="klayout_${KLAYOUT_VERSION}-1_amd64.deb"
      PKG_URL="${BASE_URL}/${folder}/${PKG_NAME}"
      PKG_LABEL="${folder} ${KLAYOUT_VERSION}"
    fi
  fi
}

download_package() {
  need_cmd curl
  run mkdir -p "$DOWNLOAD_DIR"
  PKG_PATH="${DOWNLOAD_DIR}/${PKG_NAME}"

  log "OS: ${OS_PRETTY:-$OS_ID $OS_VERSION_ID}"
  log "Mode: ${INSTALL_MODE}"
  log "Package: ${PKG_LABEL}"
  log "URL: ${PKG_URL}"
  log "Saving to: ${PKG_PATH}"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi

  if ! curl -fL --retry 3 --retry-delay 2 -o "$PKG_PATH" "$PKG_URL"; then
    die "Download failed. Check version/OS at https://www.klayout.de/build.html"
  fi

  if [[ ! -s "$PKG_PATH" ]]; then
    die "Downloaded file is empty: $PKG_PATH"
  fi
}

find_libdir() {
  local root="$1"
  if [[ -d "$root/usr/lib64/klayout" ]]; then
    printf '%s' "$root/usr/lib64/klayout"
  elif [[ -d "$root/usr/lib/klayout" ]]; then
    printf '%s' "$root/usr/lib/klayout"
  elif [[ -d "$root/usr/lib/x86_64-linux-gnu/klayout" ]]; then
    printf '%s' "$root/usr/lib/x86_64-linux-gnu/klayout"
  else
    # Fall back to common locations
    printf '%s' "$root/usr/lib64/klayout"
  fi
}

write_launcher() {
  local launcher="$1"
  local bindir="$2"
  local libdir="$3"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] write launcher %s -> %s (lib=%s)\n' "$launcher" "$bindir/klayout" "$libdir"
    return 0
  fi

  cat >"$launcher" <<EOF
#!/usr/bin/env bash
# Auto-generated by install-klayout.sh
export LD_LIBRARY_PATH="${libdir}\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "${bindir}/klayout" "\$@"
EOF
  chmod 755 "$launcher"
}

install_user() {
  local extract_dir="${DOWNLOAD_DIR}/extract"
  local bindir libdir launcher

  log "User install prefix: ${PREFIX}"
  run mkdir -p "$PREFIX" "$extract_dir" "$BIN_LINK_DIR"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Would extract ${PKG_KIND} into ${PREFIX}"
    write_launcher "${BIN_LINK_DIR}/klayout" "${PREFIX}/usr/bin" "$(find_libdir "$PREFIX")"
    return 0
  fi

  # Clean previous extract layout under prefix (keep PREFIX itself)
  rm -rf "${PREFIX}/usr"

  if [[ "$PKG_KIND" == "rpm" ]]; then
    need_cmd rpm2cpio
    need_cmd cpio
    log "Extracting RPM into ${PREFIX}..."
    (
      cd "$extract_dir"
      rpm2cpio "$PKG_PATH" | cpio -idm --quiet
    )
  else
    need_cmd dpkg-deb
    log "Extracting DEB into ${PREFIX}..."
    dpkg-deb -x "$PKG_PATH" "$extract_dir"
  fi

  # Move extracted tree into PREFIX
  if [[ -d "${extract_dir}/usr" ]]; then
    cp -a "${extract_dir}/usr" "$PREFIX/"
  else
    die "Unexpected package layout (no usr/ after extract)"
  fi

  bindir="${PREFIX}/usr/bin"
  libdir="$(find_libdir "$PREFIX")"
  [[ -x "${bindir}/klayout" ]] || die "klayout binary missing after extract: ${bindir}/klayout"
  [[ -d "$libdir" ]] || die "klayout libraries missing after extract: ${libdir}"

  launcher="${BIN_LINK_DIR}/klayout"
  log "Writing launcher: ${launcher}"
  write_launcher "$launcher" "$bindir" "$libdir"

  # Also wrap stream tools if present
  local tool
  for tool in "${bindir}"/strm*; do
    [[ -e "$tool" ]] || continue
    local name
    name="$(basename "$tool")"
    cat >"${BIN_LINK_DIR}/${name}" <<EOF
#!/usr/bin/env bash
export LD_LIBRARY_PATH="${libdir}\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "${bindir}/${name}" "\$@"
EOF
    chmod 755 "${BIN_LINK_DIR}/${name}"
  done

  log "Installed binaries under ${bindir}"
  log "Libraries under ${libdir}"
  if [[ ":${PATH}:" != *":${BIN_LINK_DIR}:"* ]]; then
    warn "Add to PATH: export PATH=\"${BIN_LINK_DIR}:\$PATH\""
  fi
}

install_system() {
  if [[ "$PKG_KIND" == "rpm" ]]; then
    if command -v dnf >/dev/null 2>&1; then
      log "Installing with dnf..."
      run dnf install -y "$PKG_PATH"
    elif command -v yum >/dev/null 2>&1; then
      log "Installing with yum..."
      run yum install -y "$PKG_PATH"
    else
      die "Neither dnf nor yum found"
    fi
  else
    need_cmd apt-get
    log "Installing with apt..."
    run apt-get update -y
    run apt-get install -y "$PKG_PATH" || run apt-get install -y -f
  fi
}

verify_install() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Dry-run complete"
    return 0
  fi

  local klayout_bin=""
  if [[ "$INSTALL_MODE" == "user" && -x "${BIN_LINK_DIR}/klayout" ]]; then
    klayout_bin="${BIN_LINK_DIR}/klayout"
  elif command -v klayout >/dev/null 2>&1; then
    klayout_bin="$(command -v klayout)"
  fi

  if [[ -n "$klayout_bin" ]]; then
    log "Installed: ${klayout_bin}"
    "$klayout_bin" -v 2>/dev/null || "$klayout_bin" -h 2>&1 | head -n 3 || true
  else
    warn "klayout not found on PATH after install"
  fi
}

cleanup() {
  if [[ "$KEEP_PKG" -eq 1 || "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  if [[ -n "${DOWNLOAD_DIR:-}" && -d "$DOWNLOAD_DIR" ]]; then
    rm -rf "$DOWNLOAD_DIR"
  fi
}

main() {
  detect_os
  resolve_mode
  resolve_package
  download_package
  if [[ "$INSTALL_MODE" == "user" ]]; then
    install_user
  else
    install_system
  fi
  verify_install
  cleanup
  log "Done."
}

trap cleanup EXIT
main "$@"
