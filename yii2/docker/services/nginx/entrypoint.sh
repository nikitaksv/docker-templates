#!/bin/bash
set -e
HOSTNAME=$(hostname -d)

sed -i "s/mydomain/$HOSTNAME/g" /etc/nginx/conf.d/frontend.conf
sed -i "s/mydomain/$HOSTNAME/g" /etc/nginx/conf.d/backend.conf

exec "$@"