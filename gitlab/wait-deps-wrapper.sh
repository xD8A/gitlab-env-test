#!/bin/sh

set -e

until PGPASSWORD=$GITLAB_DATABASE_PASSWORD pg_isready -h "$GITLAB_DATABASE_HOST" -U "$GITLAB_DATABASE_USERNAME"; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"
exec "$@"
