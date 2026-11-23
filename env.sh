#!/bin/sh
export FQDN=

export CONNECT_CONFIG_TPL=./config/connect/rstudio-connect.gcfg

# install/get-rlang.sh
export R_VERSION=4.6.2

# install/get-python.sh
export PYTHON_VERSION=3.13.18

# install/get-quarto.sh
export QUARTO_VERSION=1.9.38

# db/pg-connection.sh
export PGHOST=127.0.0.1
export PGPORT=5432
export PGDATABASE=testdb
export PGUSER=testuser
export PGPASSWORD=testpass

# e.g. echo 'password' | enc-value-connect
# export PGPASSWORD_ENCRYPTED=$(echo $PGPASSWORD | enc-value-connect)

# db/pg-connection-r.sh
#export PG_DSN="${PG_DSN:-postgresql-test}"

export SSL_CERTIFICATE=
export SSL_CERTIFICATE_KEY=

# config/connect/rstudio-connect.gcfg [OAuth2]
export OAUTH_CLIENT_ID=
export OAUTH_CLIENT_SECRET=
export OAUTH_ISSUER=

# export OAUTH_CLIENT_SECRET_ENCRYPTED=$(echo $OAUTH_CLIENT_SECRET | enc-value-connect)

export CONNECT_DATA_DIR=/opt/connect-data

# export FOO=$(echo $PGPASSWORD | base64)

export R_PACKAGE_REPOSITORY=https://packagemanager.posit.co/cran/__linux__/$(lsb_releases -cs)/latest

# export BAR=FOO

