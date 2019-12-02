#!/bin/bash
set -e

# common verdi entrypoint tasks
. /entrypoint-verdi-common.sh

exec gosu $UID:$GID "$@"
