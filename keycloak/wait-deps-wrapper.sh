#!/bin/sh

set -e

>&2 echo "Sleeping"
sleep 10
exec "$@"

