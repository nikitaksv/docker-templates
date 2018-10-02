ARG PHP_TAG_VERSION=${PHP_TAG_VERSION}
FROM php:${PHP_TAG_VERSION}

# ENV declarations 
ENV COMPOSER_ALLOW_SUPERUSER 1

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        zip \
        unzip \
    && pecl install xdebug

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer selfupdate

ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /bin/wait-for-it
COPY ./config/ /usr/local/etc/php/
COPY ./scripts/ /scripts/

RUN chmod a+x -R /scripts/ \
    && cp -r /scripts/* /bin/ \
    && chmod a+x /bin/wait-for-it

WORKDIR /var/www/html/

ENTRYPOINT [ "entrypoint.sh" ]

CMD [ "php-fpm" ]