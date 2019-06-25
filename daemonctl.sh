#!/bin/bash
set -e
cd "$(dirname "$0")"
_basement=$PWD
_action=$1

APP_NAME="hello-golang"

container_clean() {
    _name=$1
    if [ "$(docker ps -aq -f name=^/$_name)" ]; then
        if [ "$(docker ps -aq -f status=running -f name=^/$_name)" ]; then
            echo "=> Stopping $_name"
            docker stop $_name
        fi
        echo "=> Remove $_name"
        docker rm $_name
    fi
}

_start() {
    if [ ! "$(docker network ls --format '{{split .Name ":"}}' | fgrep ${APP_NAME})" ]; then
        echo ":: Creating Docker Network: ${APP_NAME}"
        docker network create ${APP_NAME}
    fi

    container_clean ${APP_NAME}_postgresql
    if [ ! "$(docker ps -aq -f status=running -f name=^/${APP_NAME}_postgresql$)" ]; then
        if [ ! -e $_basement/local/${APP_NAME}_postgresql ]; then
            mkdir -p $_basement/local/${APP_NAME}_postgresql
            echo ":: Created database directory"
        fi

        docker run --name ${APP_NAME}_postgresql --network ${APP_NAME} \
            -u $(id -u):$(id -g) \
            -p 5432:5432 \
            -e POSTGRES_USER="postgres" \
            -e POSTGRES_PASSWORD="postgres" \
            -e POSTGRES_DB="hello_golang" \
            -v $_basement/local/${APP_NAME}_postgresql:/var/lib/postgresql/data \
            -v $_basement/sql:/docker-entrypoint-initdb.d:ro \
            -dit postgres:11.3
    fi
}

_stop() {
    container_clean ${APP_NAME}_postgresql
}

if [ "$_action" = "start" ]; then
    _start
elif [ "$_action" = "stop" ]; then
    _stop
else
    echo "Usage: daemonctl <start/stop>"
fi

