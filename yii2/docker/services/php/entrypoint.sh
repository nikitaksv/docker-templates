#!/bin/bash
set -e
mkdir -p /var/log/php
wait-for-it -t 0 mysql:3306
### SET CUSTOM CONFIG php.ini
if [ ! -z "$PHP_INI_CUSTOM_CONFIG" ]; then
    echo "---------------> set custom config to php.ini"
    printf $PHP_INI_CUSTOM_CONFIG'\n' > /usr/local/etc/php/php.ini
fi
if [ $PHP_XDEBUG_ENABLE = 1 ]; then
    if [ ! -f "/tmp/xdebugcheck" ]; then
        sed -i "s/xdebug.idekey=PHPSTORM/xdebug.idekey=$PHP_XDEBUG_IDE_KEY/g" /usr/local/etc/php/conf.d/xdebug.ini
        sed -i "s/xdebug.remote_port=9000/xdebug.remote_port=$PHP_XDEBUG_REMOTE_PORT/g" /usr/local/etc/php/conf.d/xdebug.ini
        docker-php-ext-enable xdebug
        if [ ! -f "/var/log/php/xdebug.log" ]; then
            touch /var/log/php/xdebug.log
        fi
        touch /tmp/xdebugcheck
    fi
fi
### DEPLOY PROJECT
if [ ! -d "vendor" ]; then
    composer install
    if [ "YII_ENV_DEV" = 0 ]; then
        php init --env=Production --overwrite=No
    else
        php init --env=Development --overwrite=No
    fi
    ln -s ../vendor/bower-asset vendor/bower
    php yii migrate --interactive=0
fi
chown -R www-data:www-data /var/log/php

exec "$@"