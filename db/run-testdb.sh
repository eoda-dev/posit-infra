#!/bin/sh
sudo apt install -y podman

# Keep rootless containers running after logout (root containers don't need it)
if [ "$(id -u)" -ne 0 ]; then
  sudo loginctl enable-linger "$(id -un)"
fi

PG_CONTAINER="${PG_CONTAINER:-pg-test}"

# Named volume keeps the data when the container is removed (--rm)
VOLUME="${PG_CONTAINER}-data"
podman volume exists "$VOLUME" || podman volume create "$VOLUME"

podman run -d --name "$PG_CONTAINER" \
  --rm \
  -e POSTGRES_USER="${PGUSER:-testuser}" \
  -e POSTGRES_PASSWORD="${PGPASSWORD:-testpass}" \
  -e POSTGRES_DB="${PGDATABASE:-testdb}" \
  -v "$VOLUME":/var/lib/postgresql/data \
  -p "${PGPORT:-5432}":5432 \
  docker.io/library/postgres:17
