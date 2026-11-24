```bash
# run-testdb (start a PostgreSQL 17 test container via podman, port 5432)
curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/run-testdb.sh | sh

# test-pg-conn (test ODBC connection to PostgreSQL)
curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/test-pg-conn.sh | sh

curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/test-pg-conn.sh | PGHOST=127.0.0.1 PGPORT=5432 PGDATABASE=testdb PGUSER=testuser PGPASSWORD=testpass sh
```
