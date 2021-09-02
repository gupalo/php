#!/usr/bin/env bash

sudo chmod 0666 /usr/local/etc/php-fpm.d/zz-docker.conf
sudo cat /usr/local/etc/php/zz-docker.conf.dist \
    | sed "s%{PHP_TIMEOUT}%${PHP_TIMEOUT}%g" \
    > /usr/local/etc/php-fpm.d/zz-docker.conf

echo "Waiting for lock (main)..."
(
    flock -w 600 200 || exit 1

    echo "Lock acquired (main)..."

    sudo mkdir -p /code/var/cache /code/var/log /code/var/sessions
    sudo chown www-data:www-data /code/var /code/var/* /code/var/log/* 2>/dev/null
    sudo chmod 0777 /code/var /code/var/* /code/var/log/* 2>/dev/null

    if [ "${APP_ENV}" = "dev" ]; then
        sudo -E /usr/local/bin/composer install -n --prefer-dist -o -d /code
    else
        sudo -E /usr/local/bin/composer install -n --prefer-dist --no-dev -o -d /code
        sudo -E /usr/local/bin/composer dump-env prod
    fi
    sudo rm -rf /tmp/symfony-cache
    sudo chown -R www-data:www-data /code/var
    sudo chmod -R 0777 /code/var

    if [ -d /code/src/Migrations ] || [ -d /code/migrations ] ; then
        (
            ${CONSOLE} doctrine:database:create --if-not-exists
            #${CONSOLE} doctrine:migrations:sync-metadata-storage
            ${CONSOLE} doctrine:migrations:migrate -n
        )
    fi
) 200>/code/var/log/init.lock
echo "Lock released (main)"
