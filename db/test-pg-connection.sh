#!/bin/sh
set -eu

# Connection settings, override via env vars, e.g.:
#   PGHOST=db.example.com PGUSER=alice PGPASSWORD=secret ./test-pg-connection.sh
PGHOST="${PGHOST:-127.0.0.1}"
PGPORT="${PGPORT:-5432}"
PGDATABASE="${PGDATABASE:-testdb}"
PGUSER="${PGUSER:-testuser}"
PGPASSWORD="${PGPASSWORD:-testpass}"
# Driver name as listed in /etc/odbcinst.ini
ODBC_DRIVER="${ODBC_DRIVER:-PostgreSQL}"

sudo apt install -y unixodbc odbc-postgresql

isql -v -k "DRIVER={${ODBC_DRIVER}};SERVER=${PGHOST};PORT=${PGPORT};DATABASE=${PGDATABASE};UID=${PGUSER};PWD=${PGPASSWORD}"
