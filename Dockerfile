FROM php:7.4-fpm

ENV DEBIAN_FRONTEND="noninteractive"
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        sudo wget netcat libcurl4-openssl-dev curl git unzip libzip-dev zlib1g-dev libpng-dev apt-utils \
        iputils-ping golang; \
    apt-get clean; rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*;

RUN docker-php-ext-install pdo pdo_mysql curl opcache zip gd

RUN echo "realpath_cache_size=4096k" >> /usr/local/etc/php/conf.d/zzz.ini; \
    echo "realpath_cache_ttl=7200" >> /usr/local/etc/php/conf.d/zzz.ini; \
    echo "date.timezone=Europe/Kiev" >> /usr/local/etc/php/conf.d/zzz.ini; \
    echo "session.cookie_lifetime=86400" >> /usr/local/etc/php/conf.d/zzz.ini; \
    echo "session.gc_maxlifetime=86400" >> /usr/local/etc/php/conf.d/zzz.ini; \
    echo "max_execution_time=300" >> /usr/local/etc/php/conf.d/zzz.ini; \
    echo "memory_limit=8G" >> /usr/local/etc/php/conf.d/zzz.ini; \
    echo "[global]" >> /usr/local/etc/php/zz-docker.conf.dist; \
    echo "daemonize = no" >> /usr/local/etc/php/zz-docker.conf.dist; \
    echo "[www]" >> /usr/local/etc/php/zz-docker.conf.dist; \
    echo "listen = 0.0.0.0:9000" >> /usr/local/etc/php/zz-docker.conf.dist; \
    echo "request_terminate_timeout = {PHP_TIMEOUT}" >> /usr/local/etc/php/zz-docker.conf.dist;

#ENV COMPOSER_AUTH='{"http-basic": {"xxx.com": {"username": "yyy", "password": "zzz"}}}'
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir "/usr/local/bin" --filename composer; \
    usermod -u 2000 www-data; adduser www-data sudo; echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers;

WORKDIR /code/
VOLUME /code

COPY ./php/ /opt/php/

USER www-data

CMD ["/opt/php/fpm.sh"]
