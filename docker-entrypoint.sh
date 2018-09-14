#!/bin/bash
set -e

term_handler() {
  exec gosu "/opt/mongodb/mms/bin/mongodb-mms stop"
}

if [ "$1" = 'ops-manager' -a "$(id -u)" = '0' ]; then
  exec gosu "/opt/mongodb/mms/bin/mongodb-mms start"
fi

trap 'sigterm_handler' SIGTERM

exec "$@"
