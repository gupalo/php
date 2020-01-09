#!/usr/bin/env bash

DEBUG_PARAMS=""
[[ -z ${DEBUG} ]] && DEBUG=0
[[ -z ${THREAD_NO} ]] && THREAD_NO=1
[[ -z ${THREAD_COUNT} ]] && THREAD_COUNT=1
[[ -z ${APP_ENV} ]] && APP_ENV="prod"
[[ -z ${DB_HOST} ]] && DB_HOST="db"
[[ -z ${CONSOLE} ]] && CONSOLE="/code/bin/console"

[[ ${DEBUG} == 1 ]] && DEBUG_PARAMS="-v"
[[ ${DEBUG} == 2 ]] && DEBUG_PARAMS="-vv"
[[ ${DEBUG} == 3 ]] && DEBUG_PARAMS="-vvv"

if [[ ${APP_ENV} == prod ]];
then
    # wait for DB
    until nc -z ${DB_HOST} 3306; do
        echo "$(date) - waiting for ${DB_HOST}..."
        sleep 3
    done
    echo "Start processing thread ${THREAD_NO} from ${THREAD_COUNT} ..."
    while true; do
        ${CONSOLE} "$@" ${DEBUG_PARAMS}
        sleep 10
    done
else
    echo "Nothing interesting here ..."
    while true; do
        sleep 3600
    done
fi
