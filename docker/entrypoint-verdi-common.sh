#!/bin/bash

# generate ssh keys
gosu 0:0 ssh-keygen -A 2>/dev/null

# common entrypoint tasks
. /entrypoint-common.sh

# update ownership of other files
#gosu 0:0 chown -R $UID:$GID /var/log/supervisor 2>/dev/null || true

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

# set supervisord options
if [[ "$#" -eq 1  && "$@" == "supervisord" ]]; then
  set -- supervisord -n
else
  if [ "${1:0:1}" = '-' ]; then
    set -- supervisord "$@"
  fi
fi
