#!/usr/bin/env bash

[[ -z ${APP_ENV} ]] && APP_ENV="prod"
[[ -z ${DB_HOST} ]] && DB_HOST=""
[[ -z ${DB_PORT} ]] && DB_PORT="3306"
[[ -z ${DEBUG} ]] && DEBUG=0
[[ -z ${DEBUG_PARAMS} ]] && DEBUG_PARAMS=""
[[ -z ${DEBUG_PARAMS} && ${DEBUG} == 1 ]] && DEBUG_PARAMS="-v"
[[ -z ${DEBUG_PARAMS} && ${DEBUG} == 2 ]] && DEBUG_PARAMS="-vv"
[[ -z ${DEBUG_PARAMS} && ${DEBUG} == 3 ]] && DEBUG_PARAMS="-vvv"
[[ -z ${THREAD_NO} ]] && THREAD_NO=1
[[ -z ${THREAD_COUNT} ]] && THREAD_COUNT=1
[[ -z ${CONSOLE} ]] && CONSOLE="/code/bin/console"
[[ -z ${PHP_TIMEOUT} ]] && PHP_TIMEOUT="300"
[[ -z ${SKIP_DEV_SLEEP} ]] && SKIP_DEV_SLEEP="0"
[[ -z ${SLEEP} ]] && SLEEP="0"
[[ -z ${DCN_HOST} ]] && DCN_HOST="dcn"
[[ -z ${DCN_PORT} ]] && DCN_PORT="80"

if [[ "${THREAD_NO}" == "auto" ]]; then
    until nc -z ${DCN_HOST} ${DCN_PORT}; do
        echo "$(date) - waiting for ${DCN_HOST}..."
        sleep 3
    done

    THREAD_NO=`curl -s "http://${DCN_HOST}:${DCN_PORT}/$(hostname)"`
    [[ -z ${THREAD_NO} ]] && echo "Cannot get THREAD_NO: ${THREAD_NO}" && exit 2
    echo "THREAD_NO: ${THREAD_NO}"
fi

if [[ "${DB_HOST}" != "" ]]; then
    # wait for DB
    until nc -z ${DB_HOST} ${DB_PORT}; do
        echo "$(date) - waiting for ${DB_HOST}..."
        sleep 3
    done
fi

if [[ ${APP_ENV} != "prod" && ${SKIP_DEV_SLEEP} == "0" ]]; then
    echo "Dev sleep..."
    while true; do
        sleep 3600
    done
    exit
fi

echo "Waiting for lock..."
sudo mkdir -p /code/var/log
sudo chown www-data:www-data /code/var/log/ /code/var/log/* 2>/dev/null
sudo chmod 0755 /code/var/log /code/var/log/* 2>/dev/null
(
    flock -w 600 200 || exit 1
) 200>/code/var/log/init.lock
echo "Lock released"
