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

set_config() {
    key="$1"
    value="$2"
    if grep -q "$key" "$config_tmp"; then
      sed_escaped_value="$(echo "$value" | sed 's/[\/&]/\\&/g')"
      sed -ri "s/^($key)[ ]*=.*$/\1=$sed_escaped_value/" "$config_tmp"
    else
      echo $'\r'"$key=$value" >> "$config_tmp"
    fi
}

set_java_opt() {
  key="$1"
  value="$2"
  sed -ri "s/(-$key)[0-9]+./\1$2/i" "$config_tmp"
}

if [ "$1" = 'mongodb-mms' ]; then

  chown -R  $MONGO_ENTERPRISE_MANAGER_USER:$MONGO_ENTERPRISE_MANAGER_USER \
            $MONGO_ENTERPRISE_MANAGER_CONF_DIR \
            $MONGO_ENTERPRISE_MANAGER_CERT_DIR \
            $MONGO_ENTERPRISE_MANAGER_LOG_DIR

  cp -n -r  $MONGO_ENTERPRISE_MANAGER_CONF_ORIG_DIR/. $MONGO_ENTERPRISE_MANAGER_CONF_DIR

  # NOTE: CONF-MMS.PROPERTIES - MAIN APP SETTINGS
  config_tmp="$(mktemp)"
  cat $MONGO_ENTERPRISE_MANAGER_CONF_DIR/conf-mms.properties > "$config_tmp"

  set_config mms.ignoreInitialUiSetup "true"
  set_config mongo.mongoUri "$MONGO_ENTERPRISE_MANAGER_DB_URI"
  set_config mms.centralUrl "$MONGO_ENTERPRISE_MANAGER_BOOTSTRAP_MAIN_URL"
  set_config mms.backupCentralUrl "$MONGO_ENTERPRISE_MANAGER_BOOTSTRAP_BACKUP_URL"
  set_config mms.adminEmailAddr "$MONGO_ENTERPRISE_MANAGER_ADMIN_EMAIL"
  # some initial configs, idk why they are mandatory
  # feel free to to remove hardcode here
  set_config mms.fromEmailAddr "$MONGO_ENTERPRISE_MANAGER_ADMIN_EMAIL"
  set_config mms.replyToEmailAddr "$MONGO_ENTERPRISE_MANAGER_ADMIN_EMAIL"
  set_config mms.mail.transport "smtp"
  set_config mms.mail.hostname "localhost"
  set_config mms.mail.port "25"

  cat "$config_tmp" > $MONGO_ENTERPRISE_MANAGER_CONF_DIR/conf-mms.properties
  rm "$config_tmp"
  # ENOT #

  # NOTE: MMS.CONF - MAIN JAVA OPTS SETTINGS
  config_tmp="$(mktemp)"
  cat $MONGO_ENTERPRISE_MANAGER_CONF_DIR/mms.conf > "$config_tmp"

  #set_config JAVA_MMS_UI_OPTS "\"$MONGO_ENTERPRISE_MANAGER_JAVA_OPTS\""
  set_java_opt xss $MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XSS
  set_java_opt xmx $MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XMX
  set_java_opt xms $MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XMS
  set_java_opt xx:newsize= $MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_NEW_SIZE
  set_java_opt xmn $MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XMN
  set_java_opt XX:ReservedCodeCacheSize= $MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_RESERVED_CODE_CACHE

  cat "$config_tmp" > $MONGO_ENTERPRISE_MANAGER_CONF_DIR/mms.conf
  rm "$config_tmp"
  # ENOT #

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
