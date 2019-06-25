#!/bin/bash
set -e
cd "$(dirname "$0")" && _basement=$PWD
APP_NAME="hello-golang"

_start() {
    echo ":: Starting daemon..."
    bash ./daemonctl.sh start

    echo ":: Starting Application..."
    docker run --rm --name $APP_NAME --network hello-golang \
        -e POSTGRES_HOST="hello-golang_postgresql" \
        -p 8080:8080 \
        -dit gcr.io/laica-lunasys/hello-golang
}

_stop() {
    set +e
    echo ":: Shutdown..."
    docker stop hello-golang

    echo ":: Stopping daemon..."
    bash ./daemonctl.sh stop
    set -e
}

if [ "$1" = "start" ]; then
    _start
elif [ "$1" = "stop" ]; then
    _stop
else
    echo "Usage: launcher <start/stop>"
fi
