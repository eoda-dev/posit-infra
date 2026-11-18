#!/bin/sh
set -eu

# Default R version, override with: R_VERSION=4.5.1 ./install-r.sh
R_VERSION="${R_VERSION:-4.6.2}"

# Use sudo only when not already root
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# Detect the OS and Ubuntu version
if [ ! -r /etc/os-release ]; then
  echo "Cannot detect OS: /etc/os-release not found" >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release

if [ "${ID:-}" != "ubuntu" ]; then
  echo "This script only supports Ubuntu (detected: ${ID:-unknown})" >&2
  exit 1
fi

case "${VERSION_ID}" in
  22.04) UBUNTU_TAG="ubuntu-2204" ;;
  24.04) UBUNTU_TAG="ubuntu-2404" ;;
  26.04) UBUNTU_TAG="ubuntu-2604" ;;
  *)
    echo "Unsupported Ubuntu version: ${VERSION_ID}" >&2
    exit 1
    ;;
esac

ARCH="$(dpkg --print-architecture)"
DEB="r-${R_VERSION}_1_${ARCH}.deb"
URL="https://cdn.posit.co/r/${UBUNTU_TAG}/pkgs/${DEB}"

# Download into a temp dir that is cleaned up on exit
TMPDIR_R="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_R"' EXIT

echo "Installing R ${R_VERSION} for ${UBUNTU_TAG} (${ARCH})"
curl -fSL -o "${TMPDIR_R}/${DEB}" "$URL"

$SUDO apt-get update
$SUDO apt-get install -y "${TMPDIR_R}/${DEB}"

# Make this version the default R (-f replaces an existing link)
$SUDO ln -sf "/opt/R/${R_VERSION}/bin/R" /usr/local/bin/R
$SUDO ln -sf "/opt/R/${R_VERSION}/bin/Rscript" /usr/local/bin/Rscript

echo "Done: $(/usr/local/bin/R --version | head -n 1)"

