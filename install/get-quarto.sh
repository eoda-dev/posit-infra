#!/bin/sh
set -eu

# Default Quarto version, override with: QUARTO_VERSION=1.8.25 ./get-quarto.sh
QUARTO_VERSION="${QUARTO_VERSION:-1.9.38}"

# Use sudo only when not already root
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

if [ "$(uname -m)" = "aarch64" ]; then
  QUARTO_ARCH="arm64"
else
  QUARTO_ARCH="amd64"
fi

TARBALL="quarto-${QUARTO_VERSION}-linux-${QUARTO_ARCH}.tar.gz"
URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/${TARBALL}"
INSTALL_DIR="/opt/quarto/${QUARTO_VERSION}"

# Download into a temp dir that is cleaned up on exit
TMPDIR_Q="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_Q"' EXIT

echo "Installing Quarto ${QUARTO_VERSION} (${QUARTO_ARCH})"
curl -fSL -o "${TMPDIR_Q}/${TARBALL}" "$URL"

$SUDO mkdir -p "$INSTALL_DIR"
$SUDO tar -zxf "${TMPDIR_Q}/${TARBALL}" -C "$INSTALL_DIR" --strip-components=1

# Make this version the default quarto (-f replaces an existing link)
$SUDO ln -sf "${INSTALL_DIR}/bin/quarto" /usr/local/bin/quarto

echo "Done: quarto $(/usr/local/bin/quarto --version)"
