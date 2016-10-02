#!/bin/bash
set -e

if [[ "$1" == nginx ]] || [ "$1" == php-fpm ]; 
then
  echo "<?php phpinfo(); ?>" > /var/www/html/info.php
  chown -R 0:0 /var/www/html
  echo "Selecting configuration based on environment ..."
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
  echo "Running PHP-FPM ..."
    php-fpm --allow-to-run-as-root --nodaemonize &
  echo "Running Nginx ..."
    nginx -g 'daemon off;'
fi

exec "$@"
