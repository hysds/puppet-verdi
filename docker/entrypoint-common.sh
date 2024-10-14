#!/bin/bash

# set HOME explicitly
export HOME=/root

# get group id
GID=$(id -g)

# update ownership of other files
if [ -e /var/run/docker.sock ]; then
  gosu 0:0 chown -R $UID:$GID /var/run/docker.sock 2>/dev/null || true
fi
