#!/bin/bash
set -e

if [[ "$1" == nginx ]] || [ "$1" == php-fpm ]; 
then
  chown -R 0:0 /var/www/html
  echo "Running PHP-FPM ..."
  php-fpm --allow-to-run-as-root --nodaemonize &
  echo "Running Nginx ..."
  nginx -g 'daemon off;'
else
  exec "$@"
fi
