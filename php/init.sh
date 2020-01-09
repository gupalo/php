#!/bin/bash

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
[[ -z ${BLACKFIRE_ENABLED} ]] && BLACKFIRE_ENABLED="0"

if [[ "$DB_HOST" != "" ]]; then
    # wait for DB
    until nc -z ${DB_HOST} ${DB_PORT}; do
        echo "$(date) - waiting for ${DB_HOST}..."
        sleep 3
    done
fi

sudo chmod 0666 /usr/local/etc/php-fpm.d/zz-docker.conf
sudo cat /usr/local/etc/php/zz-docker.conf.dist \
    | sed "s%{PHP_TIMEOUT}%${PHP_TIMEOUT}%g" \
    > /usr/local/etc/php-fpm.d/zz-docker.conf

sudo mkdir -p /code/var/log /code/var/cache /code/var/sessions
sudo chown -R www-data:www-data /code/var/
sudo chmod -R 0777 /code/var/

(
    flock -w 600 200 || exit 1

    sudo mkdir -p /code/var/cache /code/var/log /code/var/sessions
    sudo chown -R www-data:www-data /code/var
    sudo chmod -R 0777 /code/var

    if [ "${APP_ENV}" = "dev" ]; then
        sudo -E /usr/local/bin/composer install -n --prefer-dist -o -d /code
    else
        sudo -E /usr/local/bin/composer install -n --prefer-dist --no-dev -o -d /code
    fi
    sudo rm -rf /tmp/symfony-cache

    if [ -d /code/src/Migrations ] || [ -d /code/migrations ] ; then
        (
            ${CONSOLE} doctrine:migrations:migrate -n
        )
    fi

    sudo chown -R www-data:www-data /code/var
    sudo chmod -R 0777 /code/var
) 200>/code/var/log/init.lock

if [[ ${APP_ENV} != prod && ${SKIP_DEV_SLEEP} == "0" ]]; then
    echo "dev sleep..."
    while true; do
        sleep 3600
    done
    exit
fi
