#!/usr/bin/env bash
set -euo pipefail

FILE=/etc/odbc.ini
DSN=postgresql-test

# create the file if it doesn't exist yet
sudo touch "$FILE"

# skip if the DSN is already there
if sudo grep -qF "[$DSN]" "$FILE"; then
    echo "DSN [$DSN] already exists in $FILE, nothing changed."
    exit 0
fi

# backup with timestamp
BACKUP="$FILE.bak.$(date +%Y%m%d-%H%M%S)"
sudo cp -p "$FILE" "$BACKUP"
echo "Backup: $BACKUP"

# append the entry (leading blank line separates it from the previous section)
sudo tee -a "$FILE" >/dev/null << 'EOF'

[postgresql-test]
Driver = PostgreSQL
Server = 127.0.0.1
Port = 5432
Database = testdb
UID = testuser
PWD = testpass
EOF

echo "Added [$DSN] to $FILE"
odbcinst -j >/dev/null 2>&1 && isql -v "$DSN" 2>/dev/null </dev/null | head -3 || true

