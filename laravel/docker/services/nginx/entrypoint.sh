#!/bin/bash
set -e

sed -i "s/lamourka.loc/$(hostname -d)/g" /etc/nginx/conf.d/site.conf

exec "$@"