#!/bin/sh
set -eu

sudo apt install -y podman

# Keep rootless containers running after logout (root containers don't need it)
if [ "$(id -u)" -ne 0 ]; then
  sudo loginctl enable-linger "$(id -un)"
fi

NAME="${NAME:-gitea}"
IMAGE="${IMAGE:-docker.io/gitea/gitea:latest}"   # Podman wants the full registry name; pin a version if you like
HTTP_PORT="${HTTP_PORT:-3000}"
SSH_PORT="${SSH_PORT:-2222}"
ADMIN_USER="${ADMIN_USER:-gitea_admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-ChangeMe123!}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"
TEST_USER="${TEST_USER:-testuser}"
TEST_PASSWORD="${TEST_PASSWORD:-ChangeMe123!}"
TEST_EMAIL="${TEST_EMAIL:-testuser@example.com}"

# Named volume keeps the data when the container is removed or recreated
VOLUME="${NAME}_data"
podman volume exists "$VOLUME" || podman volume create "$VOLUME"

# Remove an old container with the same name (the data volume is kept)
podman rm -f "$NAME" >/dev/null 2>&1 || true

podman run -d --name "$NAME" \
  --restart unless-stopped \
  -p "$HTTP_PORT:3000" \
  -p "$SSH_PORT:22" \
  -v "$VOLUME":/data \
  -e USER_UID=1000 \
  -e USER_GID=1000 \
  -e GITEA__database__DB_TYPE=sqlite3 \
  -e GITEA__security__INSTALL_LOCK=true \
  -e GITEA__server__ROOT_URL="http://localhost:$HTTP_PORT/" \
  -e GITEA__server__SSH_PORT="$SSH_PORT" \
  "$IMAGE" >/dev/null

printf 'Waiting for Gitea'
i=0
until curl -fsS "http://localhost:$HTTP_PORT/api/healthz" >/dev/null 2>&1; do
  i=$((i + 1))
  [ "$i" -gt 60 ] && { echo; echo "Gitea did not become ready, see: podman logs $NAME" >&2; exit 1; }
  printf '.'
  sleep 2
done
echo

# Create a user, or skip if it already exists (e.g. data volume reused)
# Usage: create_user USERNAME PASSWORD EMAIL [--admin]
create_user() {
  if podman exec -u git "$NAME" gitea admin user list 2>/dev/null | grep -qw "$1"; then
    echo "User '$1' already exists"
  else
    podman exec -u git "$NAME" gitea admin user create \
      --username "$1" \
      --password "$2" \
      --email "$3" \
      --must-change-password=false \
      ${4:+"$4"}
  fi
}

create_user "$ADMIN_USER" "$ADMIN_PASSWORD" "$ADMIN_EMAIL" --admin
create_user "$TEST_USER" "$TEST_PASSWORD" "$TEST_EMAIL"

echo "Gitea:    http://localhost:$HTTP_PORT"
echo "Admin:    $ADMIN_USER / $ADMIN_PASSWORD"
echo "User:     $TEST_USER / $TEST_PASSWORD"

