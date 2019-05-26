#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)


# usage
usage() {
  echo "usage: $0 <release tag>" >&2
}


# check usage
if [ $# -ne 1 ]; then
  usage
  exit 1
fi
release=$1


# print out commands and exit on any errors
set -ex

# set oauth token
OAUTH_CFG="$HOME/.git_oauth_token"
if [ -e "$OAUTH_CFG" ]; then
  source $OAUTH_CFG
  GIT_URL="https://${GIT_OAUTH_TOKEN}@github.com"
else
  GIT_URL="https://github.com"
fi


# clone hysds-framework
cd $HOME
PACKAGE=hysds-framework
if [ ! -d "$HOME/$PACKAGE" ]; then
  git clone ${GIT_URL}/hysds/${PACKAGE}.git
fi
cd $HOME/$PACKAGE
if [ "$release" = "develop" ]; then
  ./install.sh -d verdi
else
  ./install.sh -r $release verdi
fi


VERDI_DIR=<%= @verdi_dir %>
WORK_DIR=<%= @work_dir %>


# source virtualenv
source $VERDI_DIR/bin/activate


# extract beefed autoindex
if [ ! -d "$WORK_DIR/.index-style" ]; then
  cd $WORK_DIR
  tar xvfj $VERDI_DIR/src/beefed-autoindex-open_in_new_win.tbz2
fi
