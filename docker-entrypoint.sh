#!/bin/bash
set -e

export TERM="xterm"

stop_mongodb_mms()
{
    echo "Stopping MongoDB Ops Manager [Daemon]..."
    /opt/mongodb/mms/bin/mongodb-mms stop
}
stop_mongodb_mms_backup()
{
    echo "Stopping MongoDB Ops Manager [Backup Daemon]..."
    /opt/mongodb/mms/bin/mongodb-mms stop
}

if [ "$1" = 'mongodb-mms' ]; then

  chown -R  $MONGO_ENTERPRISE_MANAGER_USER:$MONGO_ENTERPRISE_MANAGER_USER \
            $MONGO_ENTERPRISE_MANAGER_CONF_DIR \
            $MONGO_ENTERPRISE_MANAGER_CERT_DIR \
            $MONGO_ENTERPRISE_MANAGER_LOG_DIR

  cp -n -r  $MONGO_ENTERPRISE_MANAGER_CONF_ORIG_DIR/. $MONGO_ENTERPRISE_MANAGER_CONF_DIR

  trap stop_mongodb_mms HUP INT QUIT KILL TERM

  echo "MongoDB Ops Manager [Daemon] is starting..."
  mongodb-mms start
  echo "MongoDB Ops Manager [Daemon] is running"

  while true; do
    sleep 1000
  done

fi

if [ "$1" = 'backup-daemon' ]; then

  trap stop_mongodb_mms_backup HUP INT QUIT KILL TERM

  echo "MongoDB Ops Manager [Backup Daemon] is starting..."
  mongodb-mms-backup-daemon start
  echo "MongoDB Ops Manager [Backup Daemon] is running"

fi



exec "$@"
