#!/bin/sh
sudo apt install -y podman

# Keep rootless containers running after logout (root containers don't need it)
if [ "$(id -u)" -ne 0 ]; then
  sudo loginctl enable-linger "$(id -un)"
fi

# Named volume keeps the data when the container is removed (--rm)
VOLUME=pg-test-data
podman volume exists "$VOLUME" || podman volume create "$VOLUME"

podman run -d --name pg-test \
  --rm \
  -e POSTGRES_USER=testuser \
  -e POSTGRES_PASSWORD=testpass \
  -e POSTGRES_DB=testdb \
  -v "$VOLUME":/var/lib/postgresql/data \
  -p 5432:5432 \
  docker.io/library/postgres:17
