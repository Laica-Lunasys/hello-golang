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

_postgresql() {
    if [ "$1" = "start" ]; then
        container_clean ${APP_NAME}_postgresql

        if [ ! -e $_basement/local/${APP_NAME}_postgresql ]; then
            mkdir -p $_basement/local/${APP_NAME}_postgresql
            echo ":: Created database directory"
        fi

        echo "=> Starting ${APP_NAME}_postgresql"
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

    if [ "$1" = "stop" ]; then
        container_clean ${APP_NAME}_postgresql
    fi
}

_caddy() {
    if [ "$1" = "start" ]; then
        container_clean ${APP_NAME}_caddy

        if [ ! -e $_basement/local/${APP_NAME}_caddy ]; then
            mkdir -p $_basement/local/${APP_NAME}_caddy
            echo ":: Created caddy directory"
        fi

        echo "=> Starting ${APP_NAME}_caddy"
        docker run --name ${APP_NAME}_caddy --network ${APP_NAME} \
            -p 80:80 \
            -p 443:443 \
            -v $_basement/Caddyfile:/etc/Caddyfile \
            -v $_basement/local/caddy:/root/.caddy \
            -dit abiosoft/caddy -agree=true --email=support@synchthia.net --host hello-golang.lunasys.dev --conf /etc/Caddyfile
    fi

    if [ "$1" = "stop" ]; then
        container_clean ${APP_NAME}_caddy
    fi
}

if [ "$1" = "start" ]; then
    if [ ! "$(docker network ls --format '{{split .Name ":"}}' | fgrep ${APP_NAME})" ]; then
        echo ":: Creating Docker Network: ${APP_NAME}"
        docker network create ${APP_NAME}
    fi

    if [ "$2" = "postgres" ] || [ "$2" = "postgresql" ] || [ "$2" = "--all" ]; then
        _postgresql start
    fi

    if [ "$2" = "caddy" ] || [ "$2" = "--all" ]; then
        _caddy start
    fi
fi

if [ "$1" = "stop" ]; then
    set +e
    if [ "$2" = "caddy" ] || [ "$2" = "--all" ]; then
        _caddy stop
    fi

    if [ "$2" = "postgres" ] || [ "$2" = "postgresql" ] || [ "$2" = "--all" ]; then
        _postgresql stop
    fi
fi

if [ "$1" = "" ] || [ "$1" = "--help" ]; then
    echo "Usage:"
    echo "daemonctl.sh <start/stop> <daemon_name/--all>"
fi
