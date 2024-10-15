#!/bin/bash


set PGPASSWORD=$POSTGRES_PASSWORD
echo "Restore data with user $POSTGRES_USER on $POSTGRES_DB database..."

pg_restore -U $POSTGRES_USER -d $POSTGRES_DB /docker-entrypoint-initdb.d/magnolia.backup

echo "Restore done."
