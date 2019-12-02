#!/bin/bash
set -e

# common verdi entrypoint tasks
. /entrypoint-verdi-common.sh

exec gosu $UID:$GID /docker-stats-on-exit-shim _docker_stats.json "$@"
