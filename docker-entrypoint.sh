#!/bin/bash
set -e

if [[ "$1" == nginx ]] || [ "$1" == php-fpm ]; 
then
  chown -R 0:0 /var/www
  cd /var/www
  if [ $CAENV = "production" ]; then mv .env.production .env; else mv .env.staging .env; fi
  echo "Setting up new relic dynamics ..."
  /newrelic.sh
  echo "Starting Sumologin collector ..."
  service collector start 
  echo "Running PHP-FPM ..."
  php-fpm --allow-to-run-as-root --nodaemonize &
  echo "Running Nginx ..."
  nginx -g 'daemon off;'
else
  exec "$@"
fi
