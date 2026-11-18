#!/bin/sh
set -eu

# Connection settings, override via env vars, e.g.:
#   PGHOST=db.example.com PGUSER=alice PGPASSWORD=secret ./pg-connection.sh
PGHOST="${PGHOST:-127.0.0.1}"
PGPORT="${PGPORT:-5432}"
PGDATABASE="${PGDATABASE:-testdb}"
PGUSER="${PGUSER:-testuser}"
PGPASSWORD="${PGPASSWORD:-testpass}"

sudo apt install unixodbc odbc-postgresql

isql -v -k "DRIVER={PostgreSQL Unicode};SERVER=${PGHOST};PORT=${PGPORT};DATABASE=${PGDATABASE};UID=${PGUSER};PWD=${PGPASSWORD}"
