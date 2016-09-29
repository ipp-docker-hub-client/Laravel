#!/bin/bash
set -e

if [[ "$1" == nginx ]] || [ "$1" == php-fpm ]; 
then
  chown -R 0:0 /var/www
  cd /var/www
  echo "Enabling configs for ${CAENV} environment ..."
    if [ $CAENV = "production" ]
    then 
      mv .env.production .env
    else 
      mv .env.staging .env
    fi
  echo "Done."
  echo "Setting up new relic configs ..."
    if [ "${NEWRELIC_LICENSE}" != "**None**" ]
    then
      sed -i "s/newrelic.license = ""/newrelic.license = "${NEWRELIC_LICENSE}"/g" /usr/local/etc/php/conf.d/newrelic.ini
      sed -i "s/;newrelic.enabled = true/newrelic.enabled = true/g" /usr/local/etc/php/conf.d/newrelic.ini
      sed -i 's/newrelic.appname = "PHP Application"/newrelic.appname = "${NEWRELIC_APPNAME}"/g' /usr/local/etc/php/conf.d/newrelic.ini
    else
      echo "No newrelic license found!"
    fi
  echo "Done."
  echo "Starting Sumologin collector ..."
    service collector start 
  echo "Running PHP-FPM ..."
    php-fpm --allow-to-run-as-root --nodaemonize &
  echo "Running Nginx ..."
    nginx -g 'daemon off;'
else
  exec "$@"
fi
