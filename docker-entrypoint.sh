#!/bin/bash
set -e

sigterm_handler() {
  exec "mongodb-mms stop"
}

if [ "$1" = 'ops-manager' -a "$(id -u)" = '0' ]; then
  exec "mongodb-mms start"
fi

trap 'sigterm_handler' SIGTERM

exec "$@"
