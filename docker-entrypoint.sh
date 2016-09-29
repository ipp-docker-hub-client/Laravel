#!/bin/bash
set -e

if [[ "$1" == nginx ]] || [ "$1" == php-fpm ]; 
then
  chown -R 0:0 /var/www
  cd /var/www
  echo "Enabling configs for ${CAENV} environment ..."
    if [ "${CAENV}" = "production" ]
    then 
      mv .env.production .env
    elif [ "${CAENV}" = "staging" ]
    then 
      mv .env.staging .env
    else
      echo "Environment veriable is not set! Task aborted."
    fi
  echo "Done."
  echo "Setting up Sumologic configs ..."
    if [ "${SUMOLOGIC_KEY}" != "**None**" ]
    then
      sed -i "s/SLNAME/"${SUMOLOGIC_NAME}"/g" /etc/sumo.conf
      sed -i "s/SLID/"${SUMOLOGIC_ID}"/g" /etc/sumo.conf
      sed -i "s/SLKEY/"${SUMOLOGIC_KEY}"/g" /etc/sumo.conf
    else
      echo "No Sumologic key found! Task aborted."
    fi
  echo "Done."
  echo "Setting up Newrelic configs ..."
    if [ "${NEWRELIC_LICENSE}" != "**None**" ]
    then
      sed -i "s/newrelic.enabled = false/newrelic.enabled = true/g" /usr/local/etc/php/conf.d/newrelic.ini
      sed -i "s/NRKEY/"${NEWRELIC_LICENSE}"/g" /usr/local/etc/php/conf.d/newrelic.ini
      sed -i 's/NRNAME/"${NEWRELIC_APPNAME}"/g' /usr/local/etc/php/conf.d/newrelic.ini
    else
      echo "No Newrelic license found! Task aborted."
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
