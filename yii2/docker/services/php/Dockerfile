ARG PHP_TAG_VERSION=${PHP_TAG_VERSION}
FROM yiisoftware/yii2-php:${PHP_TAG_VERSION}

RUN apt-get update \
    && apt-get install -y \
        libmcrypt-dev \
        libgeoip-dev \
        libmemcached-dev \
    && pecl install \
        geoip-1.1.1 \
        mcrypt-1.0.1 \
        memcached \
        redis \
        xdebug \
    && echo "extension=geoip.so" > /usr/local/etc/php/conf.d/ext-geoip.ini \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install \
        mysqli \
    && docker-php-ext-enable \
        memcached \
        redis \
        opcache \
        geoip \
    && usermod -u 1000 www-data \
    && groupmod -g 1000 www-data

COPY ./config/ /usr/local/etc/php/conf.d/
COPY entrypoint.sh /entrypoint.sh
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /bin/wait-for-it
RUN chmod a+x /entrypoint.sh \
    && chmod a+x /bin/wait-for-it

# For skip warning composer install non-root user....
ENV COMPOSER_ALLOW_SUPERUSER=1
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["php-fpm"]