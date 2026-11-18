#!/bin/sh
set -eu

# Default Python version, override with: PYTHON_VERSION=3.12.8 ./install-python.sh
PYTHON_VERSION="${PYTHON_VERSION:-3.13.18}"
INSTALL_DIR="${INSTALL_DIR:-/opt/python}"
UV_BIN_DIR="/usr/local/bin"

# Use sudo only when not already root
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# Install uv system-wide if it is missing
if [ ! -x "${UV_BIN_DIR}/uv" ]; then
  echo "Installing uv into ${UV_BIN_DIR}"
  curl -LsSf https://astral.sh/uv/install.sh \
    | $SUDO env UV_INSTALL_DIR="${UV_BIN_DIR}" UV_NO_MODIFY_PATH=1 sh
fi

# Install the requested Python (uv skips it if it is already there)
echo "Installing Python ${PYTHON_VERSION} into ${INSTALL_DIR}"
$SUDO mkdir -p "${INSTALL_DIR}"
$SUDO "${UV_BIN_DIR}/uv" python install "${PYTHON_VERSION}" --install-dir="${INSTALL_DIR}"

# Resolve the real directory (e.g. cpython-3.13.18-linux-x86_64-gnu)
set -- "${INSTALL_DIR}"/cpython-"${PYTHON_VERSION}"-*
TARGET="$1"
if [ ! -d "$TARGET" ]; then
  echo "Could not find an installed Python ${PYTHON_VERSION} in ${INSTALL_DIR}" >&2
  exit 1
fi

# Stable path: /opt/python/<version> (-n replaces an existing link instead of nesting)
$SUDO ln -sfn "$TARGET" "${INSTALL_DIR}/${PYTHON_VERSION}"

# Test
echo "Done: $("${INSTALL_DIR}/${PYTHON_VERSION}/bin/python" --version)"

