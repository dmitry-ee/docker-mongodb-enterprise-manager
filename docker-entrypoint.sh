#!/bin/bash
set -e

if [ "$1" = 'mongodb-mms' -a "$(id -u)" = '0' ]; then
  cp -n -r $MONGO_ENTERPRISE_MANAGER_OCONF_DIR/. $MONGO_ENTERPRISE_MANAGER_CONF_DIR
  supervisord
  while true; do
    sleep 60
  done
fi

exec "$@"
