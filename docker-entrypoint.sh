#!/bin/sh

while :; do
    nc -w 1 -z $POSTGRES_HOST ${POSTGRES_PORT:-5432}
    if [[ $? = 0 ]]; then
        break;
    fi
    echo ":: Waiting Establish connection to PostgreSQL ($POSTGRES_HOST:${POSTGRES_PORT:-5432})..."
    sleep 1
done

exec /app/hello-golang
