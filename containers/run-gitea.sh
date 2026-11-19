#!/bin/sh
set -eu

NAME="${NAME:-gitea}"
IMAGE="${IMAGE:-docker.io/gitea/gitea:latest}"   # Podman wants the full registry name; pin a version if you like
HTTP_PORT="${HTTP_PORT:-3000}"
SSH_PORT="${SSH_PORT:-2222}"
ADMIN_USER="${ADMIN_USER:-gitea_admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-ChangeMe123!}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"

# Remove an old container with the same name (the data volume is kept)
podman rm -f "$NAME" >/dev/null 2>&1 || true

podman run -d --name "$NAME" \
  --restart unless-stopped \
  -p "$HTTP_PORT:3000" \
  -p "$SSH_PORT:22" \
  -v "${NAME}_data:/data" \
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

# Create the admin user, or skip if it already exists (e.g. data volume reused)
if podman exec -u git "$NAME" gitea admin user list 2>/dev/null | grep -qw "$ADMIN_USER"; then
  echo "Admin user '$ADMIN_USER' already exists"
else
  podman exec -u git "$NAME" gitea admin user create \
    --admin \
    --username "$ADMIN_USER" \
    --password "$ADMIN_PASSWORD" \
    --email "$ADMIN_EMAIL" \
    --must-change-password=false
fi

echo "Gitea:    http://localhost:$HTTP_PORT"
echo "Login:    $ADMIN_USER / $ADMIN_PASSWORD"

