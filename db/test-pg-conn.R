#!/usr/bin/env Rscript
# Test the ODBC connection to the DSN in ODBCINI_DSN (default: postgresql-test)
if (!requireNamespace("odbc", quietly = TRUE)) install.packages("odbc")

odbc::dbConnect(odbc::odbc(), dsn = Sys.getenv("ODBCINI_DSN", "postgresql-test"))
