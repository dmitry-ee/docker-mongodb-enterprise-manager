#!/bin/bash
set -e

if [ "$1" = 'ops-manager' -a "$(id -u)" = '0' ]; then
  while true; do
    echo "hi there!"
    sleep 10
  done
fi

exec "$@"
