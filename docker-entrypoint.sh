#!/bin/bash
set -e

if [ "$1" = 'mongodb-mms' -a "$(id -u)" = '0' ]; then
  chown -R  $MONGO_ENTERPRISE_MANAGER_CONF_DIR \
            $MONGO_ENTERPRISE_MANAGER_CERT_DIR \
            $MONGO_ENTERPRISE_MANAGER_LOG_DIR
  cp -n -r  $MONGO_ENTERPRISE_MANAGER_CONF_ORIG_DIR/. $MONGO_ENTERPRISE_MANAGER_CONF_DIR
  supervisord
  while true; do
    sleep 60
  done
fi

exec "$@"
