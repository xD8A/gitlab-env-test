#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	-- Gitlab
    CREATE USER $GITLAB_USER;
    ALTER USER $GITLAB_USER WITH PASSWORD '$GITLAB_PASSWORD';
    CREATE DATABASE $GITLAB_DB OWNER $GITLAB_USER;

    \c $GITLAB_DB;
	CREATE EXTENSION IF NOT EXISTS pg_trgm;
	CREATE EXTENSION IF NOT EXISTS btree_gist;
	CREATE EXTENSION IF NOT EXISTS plpgsql;

	-- Keycloak
	CREATE USER $KEYCLOAK_USER;
    ALTER USER $KEYCLOAK_USER WITH PASSWORD '$KEYCLOAK_PASSWORD';
	CREATE DATABASE $KEYCLOAK_DB OWNER $KEYCLOAK_USER;

    \du+
    \l+

EOSQL
