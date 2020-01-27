PHP Base Image
==============

Image to be extended for PHP-FPM and PHP CLI. 

Env Vars
--------

* APP_ENV: dev/prod; default - prod
* DB_HOST, DB_PORT: set if you need to wait for database
* DEBUG: 0-3; 0 - silent (default), 1 - `-v`, 2 - `-vv`, 3 - `-vvv`; you can override manually in DEBUG_PARAMS
* THREAD_NO, THREAD_COUNT: if you want to split work between conainers; if THREAD_NO=auto then DCN_HOST, DCN_PORT
  are used to determine THREAD_NO (see https://github.com/gupalo/docker-container-number ) 
* CONSOLE: default `/code/bin/console`
* PHP_TIMEOUT: max timeout in seconds for php-fpm to give up; default - 300
* SKIP_DEV_SLEEP: 0/1; default - 0 - means that command entrypoints in dev env will do nothing
* SLEEP: seconds to sleep between command execution; default - 0 (repeat immediately)
* BLACKFIRE_SERVER_ID, BLACKFIRE_SERVER_TOKEN: if BLACKFIRE_ENABLED=1, will be used to configure Blackfire profiler;
  get them at https://blackfire.io/
* CODE_DIR: default `/code`; used in `server.sh` - local server without php-fpm

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

For local php server you can change entrypoint to `/opt/php/server.sh`.
