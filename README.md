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
    
    RUN sudo mkdir -p /code/var; sudo rm -rf /code/var/*; \
        /usr/local/bin/composer install -n --prefer-dist --no-dev -o -d /code;


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
        entrypoint: '/opt/php/console.sh app:command --param1=value1 --param2=value2'
