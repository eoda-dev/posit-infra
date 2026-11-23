#!/bin/sh
set -eu

FILE=/etc/odbc.ini
DSN="${ODBCINI_DSN:-postgresql-test}"

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

# append the entry
sudo tee -a "$FILE" >/dev/null << EOF

[$DSN]
Driver = PostgreSQL
Server = 127.0.0.1
Port = 5432
Database = testdb
UID = testuser
PWD = testpass
EOF

echo "Added [$DSN] to $FILE"

# optional connection test
if command -v isql >/dev/null 2>&1; then
    echo "select 1" | isql -b "$DSN" || echo "Connection test failed (check driver name and credentials)."
fi

