#!/bin/sh
# get-posit-setup.sh - set up ~/.posit-setup with env.sh, the aliases and an activate script.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/get-posit-setup.sh | sh
#   . ~/.posit-setup/activate
#
# Override the target dir with: POSIT_SETUP_DIR=/some/dir
set -eu

BASE_URL="https://raw.githubusercontent.com/eoda-dev/posit-infra/main"
SETUP_DIR="${POSIT_SETUP_DIR:-$HOME/.posit-setup}"

mkdir -p "$SETUP_DIR"

# env.sh holds your settings: keep an existing one so local edits survive a re-run
if [ -f "$SETUP_DIR/env.sh" ]; then
  echo "Keeping existing $SETUP_DIR/env.sh"
else
  curl -fsSL -o "$SETUP_DIR/env.sh" "$BASE_URL/env.sh"
  echo "Downloaded $SETUP_DIR/env.sh"
fi

# The aliases are always refreshed to the latest version
curl -fsSL -o "$SETUP_DIR/aliases.sh" "$BASE_URL/aliases.sh"
echo "Downloaded $SETUP_DIR/aliases.sh"

# activate: load the settings first, then the aliases
cat > "$SETUP_DIR/activate" << EOF
# Source this file, do not run it: . "$SETUP_DIR/activate"
. "$SETUP_DIR/env.sh"
. "$SETUP_DIR/aliases.sh"
EOF
echo "Created $SETUP_DIR/activate"

echo
echo "Activate in the current shell with:"
echo "  . \"$SETUP_DIR/activate\""
