#!/bin/sh
Rscript -e 'odbc::dbConnect(odbc::odbc(), dsn=Sys.getenv("ODBCINI_DSN", "postgresql-test"))'

