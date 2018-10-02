#!/bin/bash
set -e

########## DECLARATIONS
DOMAIN=$(hostname -d)
declare -A DEFAULT_VARS
DEFAULT_VARS["TZ"]="${TZ:=Europe/Moscow}"
DEFAULT_VARS["PHP_XDEBUG_ENABLE"]="${PHP_DEBUG_ENABLE:=1}"
DEFAULT_VARS["APP_ENV"]="${APP_ENV:=local}"
DEFAULT_VARS["PHP_XDEBUG_IDE_KEY"]="${PHP_XDEBUG_IDE_KEY:=PHPSTORM}"
DEFAULT_VARS["PHP_XDEBUG_REMOTE_PORT"]="${PHP_XDEBUG_REMOTE_PORT:=9000}"
########## END DECLARATIONS


########## FUNCTIONS

# Wait helper. Wait service 10 minutes.
# Use: wait mariadb:3306 
function wait(){
    notify 'task' "==> Wait $1 ...."
    wait-for-it --quiet -t 600 $1 -- notify 'inf' "==> Success: $1 is connected"
}

# Waiting all services
function waitServices(){
    notify 'taskgrp' "==> Task: Waiting services...."
    wait mariadb:3306
}

# Check deploy project
function checkDeploy(){
    local  __resultvar=$1
    if [ -f ".deployed" ]; then
        eval $__resultvar="1"
    else
        eval $__resultvar="0"
    fi
}

# Install composer dependencies
function installComposerDependencies(){
    notify 'taskgrp' "==> Task: Install composer dependencies..."
    composer install
}

# Fixed permssions app sources and logs files
function fixPermissions(){
    notify 'taskgrp' "==> Task: Fix permssions app sources and logs files."
    chmod -R 777 ./storage/
    notify 'inf' "Changing permissions on ./storage/"
    chown -R 1000:1000 ../html/
    notify 'inf' "Changing owner on /var/www/html/"
    chown -R www-data:www-data /var/log/
    notify 'inf' "Changing owner on /var/log/"
}

# Deploy project
function deployProject(){
    checkDeploy check
    if [ $check == '0' ]; then
        notify 'warn' "==> Warning: Project is not deployed."
        notify 'taskgrp' "====> Task: Deploy project..."
        installComposerDependencies
        configureProject
        fixPermissions
        echo "If this file exists, then the container with php, assumes that the project is deployed. Delete it if you need to re-deploy the project." > .deployed
        notify 'taskgrp' "====> Task completed: Project is deployed."
    else 
        notify 'started' "Project is deployed."
    fi

}

# Always configure. If container restarted or rebuild.
function configureAlways(){
    if [ $PHP_DEBUG_ENABLE = 1 ]; then
        if [ ! -f "/tmp/xdebugcheck" ];then
            docker-php-ext-enable xdebug   
            notify 'warn' "==> Warning: Xdebug - enabled."  
            if [ ! -f "/var/log/php/xdebug.log" ]; then
                touch /var/log/php/xdebug.log
                chown www-data:www-data /var/log/php/xdebug.log
            fi 
            sed -i "s/xdebug.idekey=PHPSTORM/xdebug.idekey=$PHP_XDEBUG_IDE_KEY/g" /usr/local/etc/php/conf.d/xdebug.ini
            sed -i "s/xdebug.remote_port=9000/xdebug.remote_port=$PHP_XDEBUG_REMOTE_PORT/g" /usr/local/etc/php/conf.d/xdebug.ini
            notify 'inf' "==> Success: xdebug.ini is configured."
            touch /tmp/xdebugcheck
        fi
    else
        sed -i "s/APP_DEBUG=true/APP_DEBUG=false/g" .env
        notify 'warn' "==> Warning: Xdebug - disabled."
        notify 'warn' "==> Warning: Project debug - disabled."
    fi
}

# Configure project
function configureProject(){
    notify 'taskgrp' "==> Task: Configure project..."
    cp .env.example .env
    sed -i "s/lamourka.loc/$DOMAIN/g" .env 
    if [ $APP_ENV == "production" ]; then
        sed -i "s/APP_ENV=local/APP_ENV=$APP_ENV/g" .env
        php artisan config:cache
        notify 'warn' "==> Project is deployed in production mode."
    fi
    php artisan key:generate
}

# Show info
function showInfo(){
    echo -e '\v'
    notify 'taskgrp' "INFO"
    echo -e '\v'
    notify 'taskgrp' "Container environments:"
    printenv
    echo -e '\v'
    notify 'taskgrp' "Project environments:"
    cat .env
    echo -e '\v'
    if [ $PHP_DEBUG_ENABLE = 1 ]; then
        echo -e '\v'
        notify 'taskgrp' "XDEBUG config (xdebug.ini):"
        cat /usr/local/etc/php/conf.d/xdebug.ini
    fi
    echo -e '\v'
}

# Start project
function start(){
    notify 'started' "==> Start..."
    waitServices
    deployProject
    configureAlways
    showInfo
}
########## END FUNCTIONS



start



notify 'started' "==> Run $@"
exec "$@"