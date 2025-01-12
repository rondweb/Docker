#!/bin/bash

# Set environment variables
export POSTGRES_USER=postgres
export POSTGRES_DB=postgres
export POSTGRES_PASSWORD=Brequois305!

# Print the environment variables to verify
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_DB: $POSTGRES_DB"
echo "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<- 'EOSQL'
CREATE DATABASE template_postgis IS_TEMPLATE true;
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
    echo "Loading PostGIS extensions into $DB"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname="$DB" <<-'EOSQL'
        CREATE EXTENSION IF NOT EXISTS postgis;
        CREATE EXTENSION IF NOT EXISTS postgis_topology;
        -- Reconnect to update pg_setting.resetval
        -- See https://github.com/postgis/docker-postgis/issues/288
        \c
        CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
        CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL
done
