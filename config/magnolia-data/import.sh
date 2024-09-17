#!/bin/bash

set PGPASSWORD=$POSTGRES_PASSWORD

pg_restore -U $POSTGRES_USER -d $POSTGRES_DB /docker-entrypoint-initdb.d/magnolia.backup
