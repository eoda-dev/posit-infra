#!/bin/sh
Rscript -e 'if (!requireNamespace("odbc", quietly = TRUE)) install.packages("odbc")' \
  -e 'odbc::dbConnect(odbc::odbc(), dsn=Sys.getenv("ODBCINI_DSN", "postgresql-test"))'
