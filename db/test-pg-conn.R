#!/usr/bin/env Rscript
# Test the ODBC connection to the DSN in ODBCINI_DSN (default: postgresql-test)
if (!requireNamespace("odbc", quietly = TRUE)) install.packages("odbc")

SCHEMA <- Sys.getenv("PG_SCHEMA", "public")

con <- odbc::dbConnect(odbc::odbc(), dsn = Sys.getenv("ODBCINI_DSN", "postgresql-test"))
print(con)
odbc::dbListTables(con, schema_name = SCHEMA)

tbl <- DBI::Id(schema = SCHEMA, table = "test_r_faithful")

if (DBI::dbExistsTable(con, tbl)) {
    message("Reading table ...")
    head(DBI::dbReadTable(con, tbl))
} else {
    odbc::dbWriteTable(con, tbl, faithful)
    message("Wrote table")
}
# DBI::dbRemoveTable(con, tbl)
print(tbl)
