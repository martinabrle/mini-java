/Applications/Postgres.app/Contents/Versions/14/bin/psql "host=${dbServerName}.postgres.database.azure.com port=5432 dbname=${dbName} user=$adminName password=$adminPassword sslmode=require" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$dbUserName'" | grep -q 1 || /Applications/Postgres.app/Contents/Versions/14/bin/psql "host=${dbServerName}.postgres.database.azure.com port=5432 dbname=${dbName} user=$adminName password=$adminPassword sslmode=require" -tAc "CREATE USER $dbUserName WITH PASSWORD '$dbUserPassword'; GRANT CONNECT ON DATABASE $dbName TO $dbUserName; GRANT USAGE ON SCHEMA public TO $dbUserName; GRANT SELECT ON todo TO $dbUserName;"


/Applications/Postgres.app/Contents/Versions/14/bin/psql "host=${dbServerName}.postgres.database.azure.com port=5432 dbname=${dbName} user=$adminName password=$adminPassword sslmode=require" -c "ALTER USER $dbUserName WITH PASSWORD 'huhuhu'; "

ALTER ROLE