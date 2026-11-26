```bash
# run-testdb (start a PostgreSQL 17 test container via podman, port 5432)
curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/run-testdb.sh | sh

# test-pg-conn (test ODBC connection to PostgreSQL)
curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/test-pg-conn.sh | sh

curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/test-pg-conn.sh | PGHOST=127.0.0.1 PGPORT=5432 PGDATABASE=testdb PGUSER=testuser PGPASSWORD=testpass sh

# test-pg-conn.R (test the odbc.ini DSN from R, writes/reads table test_r_faithful)
curl -fsSL -O https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/test-pg-conn.R
# or
wget -q https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/test-pg-conn.R

Rscript test-pg-conn.R

ODBCINI_DSN=postgresql-test PG_SCHEMA=public Rscript test-pg-conn.R
```
