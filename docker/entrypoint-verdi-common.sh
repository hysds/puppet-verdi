#!/bin/bash

# generate ssh keys
gosu 0:0 ssh-keygen -A 2>/dev/null

# common entrypoint tasks
. /entrypoint-common.sh

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
