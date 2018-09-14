#!/bin/bash
set -e

if [ "$1" = 'mongodb-mms' -a "$(id -u)" = '0' ]; then
  /usr/bin/supervisord
  while true; do
    sleep 60
  done
fi

exec "$@"
