#!/bin/sh
Rscript -e 'odbc::dbConnect(odbc::odbc(), dsn=Sys.getenv("PG_DSN", "postgresql-test"))'

