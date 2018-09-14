#!/bin/bash
set -e

sigterm_handler() {
  exec "mongodb-mms stop"
}

if [ "$1" = 'mongodb-mms' -a "$(id -u)" = '0' ]; then
  exec "mongodb-mms start"
  while true; do
    echo "$(mongodb-mms status)"
    sleep 60
  done
fi

trap 'sigterm_handler' SIGTERM

exec "$@"
