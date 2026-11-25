#!/bin/sh
set -eu

sudo apt install -y podman

# Keep rootless containers running after logout (root containers don't need it)
if [ "$(id -u)" -ne 0 ]; then
  sudo loginctl enable-linger "$(id -un)"
fi

RSTUDIO_CONTAINER="${RSTUDIO_CONTAINER:-rstudio}"
RSTUDIO_IMAGE="${RSTUDIO_IMAGE:-docker.io/rocker/rstudio:latest}"   # pin an R version if you like, e.g. rocker/rstudio:4.5
# 8788, not 8787, so it doesn't clash with a Workbench / RStudio Server on the host
RSTUDIO_PORT="${RSTUDIO_PORT:-8788}"
RSTUDIO_PASSWORD="${RSTUDIO_PASSWORD:-ChangeMe123!}"

# Named volume keeps /home/rstudio (projects, R packages, settings) when the container is removed
VOLUME="${RSTUDIO_CONTAINER}-data"
podman volume exists "$VOLUME" || podman volume create "$VOLUME"

# Remove an old container with the same name (the data volume is kept)
podman rm -f "$RSTUDIO_CONTAINER" >/dev/null 2>&1 || true

podman run -d --name "$RSTUDIO_CONTAINER" \
  --rm \
  -p "$RSTUDIO_PORT":8787 \
  -e PASSWORD="$RSTUDIO_PASSWORD" \
  -v "$VOLUME":/home/rstudio \
  "$RSTUDIO_IMAGE" >/dev/null

printf 'Waiting for RStudio'
i=0
until curl -fsS -o /dev/null "http://localhost:$RSTUDIO_PORT/" 2>/dev/null; do
  i=$((i + 1))
  [ "$i" -gt 60 ] && { echo; echo "RStudio did not become ready, see: podman logs $RSTUDIO_CONTAINER" >&2; exit 1; }
  printf '.'
  sleep 2
done
echo

echo "RStudio:  http://localhost:$RSTUDIO_PORT"
echo "Login:    rstudio / $RSTUDIO_PASSWORD"
