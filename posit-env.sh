#!/bin/sh
export FQDN=

export CONNECT_CONFIG_TPL=./config/connect/rstudio-connect.gcfg

# install/get-rlang.sh
export R_VERSION=4.6.2

# install/get-python.sh
export PYTHON_VERSION=3.13.18

# install/get-quarto.sh
export QUARTO_VERSION=1.9.38

# db
export PGHOST=127.0.0.1
export PGPORT=5432
export PGDATABASE=testdb
export PGUSER=testuser
export PGPASSWORD=testpass

# e.g. echo 'password' | enc-value-connect
# export PGPASSWORD_ENCRYPTED=$(echo $PGPASSWORD | enc-value-connect)

# db/add-odbcini-entry.sh, db/test-pg-conn-r.sh
export ODBCINI_DSN=postgresql-test

# db/run-testdb.sh (run-pg-test, stop-pg-test)
export PG_CONTAINER=pg-test

export SSL_CERTIFICATE=
export SSL_CERTIFICATE_KEY=

# config/connect/rstudio-connect.gcfg [OAuth2]
export OAUTH_CLIENT_ID=
export OAUTH_CLIENT_SECRET=
export OAUTH_ISSUER=

# export OAUTH_CLIENT_SECRET_ENCRYPTED=$(echo $OAUTH_CLIENT_SECRET | enc-value-connect)

export CONNECT_DATA_DIR=/var/lib/rstudio-connect

# export FOO=$(echo $PGPASSWORD | base64)

export R_PACKAGE_REPOSITORY=https://packagemanager.posit.co/cran/__linux__/$(lsb_release -cs)/latest

# export BAR=FOO

# ---
# Download connect template if it isn't there yet
if [ ! -f "$CONNECT_CONFIG_TPL" ]; then
  echo "Downloading $CONNECT_CONFIG_TPL"
  mkdir -p "$(dirname "$CONNECT_CONFIG_TPL")" && curl -fsSL -o "$CONNECT_CONFIG_TPL" https://raw.githubusercontent.com/eoda-dev/posit-infra/main/config/connect/rstudio-connect.gcfg || true
fi

. <(curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/aliases.sh)

