#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	-- Gitlab
    CREATE USER $GITLAB_USER;
    CREATE DATABASE $GITLAB_DB;
    ALTER USER $GITLAB_USER WITH PASSWORD '$GITLAB_PASSWORD';
    GRANT ALL PRIVILEGES ON DATABASE $GITLAB_DB TO $GITLAB_USER;

    \c $GITLAB_DB;
	CREATE EXTENSION IF NOT EXISTS pg_trgm;
	CREATE EXTENSION IF NOT EXISTS btree_gist;
	CREATE EXTENSION IF NOT EXISTS plpgsql;

EOSQL
