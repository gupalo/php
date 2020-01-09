PHP Base Image
==============

Image to be extended for PHP-FPM and PHP CLI 

Env vars
--------

Build
-----

    make build

Usage
-----

Dockerfile

    FROM gupalo/fpm

    COPY . ./
    
    RUN mkdir -p /code/var; rm -rf /code/var/*; \
        /usr/local/bin/composer install -n --prefer-dist --no-dev -o -d /code; \
        chown -R www-data:www-data /code/var;


docker-compose.yaml:

    fpm:
        image: 'gupalo/php'
        volumes: ['./log/app/:/code/var/log/']
        env_file: ['./env.conf']
        restart: 'always'
        networks: ['default']
    daemon:
        depends_on: ['fpm']
        volumes_from: ['fpm']
        env_file: ['./env.conf']
        restart: 'always'
        networks: ['default']
        entrypoint: '/code/bin/daemon.sh'
