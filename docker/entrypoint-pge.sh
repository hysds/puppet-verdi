#!/bin/bash
set -e

# common pge entrypoint tasks
. /entrypoint-pge-common.sh

exec gosu $UID:$GID "$@"
