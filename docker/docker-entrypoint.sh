#!/bin/bash
set -e

# set HOME explicitly
export HOME=/home/ops

# get group id
GID=$(id -g)

# generate ssh keys
gosu 0:0 ssh-keygen -A 2>/dev/null

# update user and group ids
gosu 0:0 groupmod -g $GID ops 2>/dev/null
gosu 0:0 usermod -u $UID -g $GID ops 2>/dev/null
gosu 0:0 usermod -aG docker ops 2>/dev/null

# update ownership
gosu 0:0 chown -R $UID:$GID $HOME 2>/dev/null || true
gosu 0:0 chown -R $UID:$GID /var/run/docker.sock 2>/dev/null || true
gosu 0:0 chown -R $UID:$GID /var/log/supervisor 2>/dev/null || true

# unpack work dir style
if [ ! -d "/data/work/.index-style" ]; then
  gosu 0:0 mkdir -p /data/work
  gosu 0:0 tar -C /data/work -xjf $HOME/verdi/src/beefed-autoindex-open_in_new_win.tbz2
  gosu 0:0 chown -R $UID:$GID /data/work 2>/dev/null || true
fi

# source bash profile
source $HOME/.bash_profile

# source verdi virtualenv
if [ -e "$HOME/verdi/bin/activate" ]; then
  source $HOME/verdi/bin/activate
fi

# extract beefed autoindex
if [[ "$#" -eq 1  && "$@" == "supervisord" ]]; then
  set -- supervisord -n
else
  if [ "${1:0:1}" = '-' ]; then
    set -- supervisord "$@"
  fi
fi

exec gosu $UID:$GID "$@"
