#!/bin/bash
set -e

# common pge entrypoint tasks
. /entrypoint-pge-common.sh

# gosu resets HOME from /etc/passwd; keep the HOME set by the entrypoint
# when the UID has no account in the image
if getent passwd "$UID" >/dev/null; then
  exec gosu $UID:$GID /docker-stats-on-exit-shim _docker_stats.json "$@"
else
  exec gosu $UID:$GID env HOME="$HOME" /docker-stats-on-exit-shim _docker_stats.json "$@"
fi
