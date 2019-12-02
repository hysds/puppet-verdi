#!/bin/bash
set -e

# common pge entrypoint tasks
. /entrypoint-pge-common.sh

exec gosu $UID:$GID /docker-stats-on-exit-shim _docker_stats.json "$@"
