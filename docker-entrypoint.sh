#!/bin/bash
set -e

if [ "$1" = 'mongodb-mms' -a "$(id -u)" = '0' ]; then

  cp -n -r  $MONGO_ENTERPRISE_MANAGER_CONF_ORIG_DIR/. $MONGO_ENTERPRISE_MANAGER_CONF_DIR

  chown -R  $MONGO_ENTERPRISE_MANAGER_USER:$MONGO_ENTERPRISE_MANAGER_USER \
            $MONGO_ENTERPRISE_MANAGER_CONF_DIR \
            $MONGO_ENTERPRISE_MANAGER_CERT_DIR \
            $MONGO_ENTERPRISE_MANAGER_LOG_DIR

  groupadd supervisor && usermod -a $MONGO_ENTERPRISE_MANAGER_USER -G supervisor

  gosu $MONGO_ENTERPRISE_MANAGER_USER supervisord

  # while true; do
  #   sleep 60
  # done

fi

exec "$@"
