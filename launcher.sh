#!/bin/bash
set -e
cd "$(dirname "$0")" && _basement=$PWD
APP_NAME="hello-golang"

container_clean() {
    _name=$1
    if [ "$(docker ps -aq -f name=^/${_name}$)" ]; then
        if [ "$(docker ps -aq -f status=running -f name=^/${_name}$)" ]; then
            echo "=> Stopping $_name"
            docker stop $_name
        fi
        echo "=> Remove $_name"
        docker rm $_name
    fi
}

_start() {
    container_clean "${APP_NAME}"

    echo ":: Starting daemon..."
    bash ./daemonctl.sh start postgresql

    if [ "$1" = "--with-caddy" ]; then
        bash ./daemonctl.sh start caddy
    fi

    echo ":: Starting Application..."
    docker run --name ${APP_NAME} --network ${APP_NAME} \
        -u $(id -u):$(id -g) \
        -e POSTGRES_HOST="hello-golang_postgresql" \
        -p 8080:8080 \
        -dit gcr.io/laica-lunasys/hello-golang
}

_stop() {
    set +e
    echo ":: Shutdown..."
    container_clean ${APP_NAME}

    echo ":: Stopping daemon..."
    bash ./daemonctl.sh stop --all
    set -e
}

if [ "$1" = "start" ]; then
    _start $2
elif [ "$1" = "stop" ]; then
    _stop
else
    echo "Usage: launcher <start [--with-caddy]/stop>"
fi
