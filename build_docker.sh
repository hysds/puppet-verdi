#!/bin/bash
if [ "$#" -ne 7 ]; then
  echo "Usage: $0 <tag> <github org> <github repo branch> <framework branch> <hysds release> <base image tag> <final tag> <base branch>"
  echo "e.g.: $0 20170620 hysds master develop v4.0.1-beta.7 latest latest develop"
  echo "e.g.: $0 latest pymonger develop develop develop develop develop master"
  exit 1
fi
TAG=$1
ORG=$2
BRANCH=$3
FRAMEWORK_BRANCH=$4
HYSDS_RELEASE=$5
BASE_IMAGE_TAG=$6
FINAL_TAG=$7
BASE_BRANCH=$8


# enable docker buildkit to allow build secrets
export DOCKER_BUILDKIT=1


# set oauth token to bypass github API rate limits
OAUTH_CFG="$HOME/.git_oauth_token"
if [ ! -e "$OAUTH_CFG" ]; then
  touch $OAUTH_CFG # create empty creds file for unauthenticated builds
fi


# build
# ./build_docker.sh 20251008 hysds docker HC-589 develop HC-589 develop
docker build --progress=plain --rm --force-rm \
  -t hysds/pge-base:${TAG} -f docker/Dockerfile.pge-base \
  --build-arg FRAMEWORK_BRANCH=${FRAMEWORK_BRANCH} \
  --build-arg HYSDS_RELEASE=${HYSDS_RELEASE} \
  --build-arg BASE_IMAGE_TAG=${BASE_IMAGE_TAG} \
  --build-arg FINAL_TAG=${FINAL_TAG} \
  --build-arg ORG=${ORG} \
  --build-arg BRANCH=${BRANCH} \
  --build-arg BASE_BRANCH=${BASE_BRANCH} \
  --secret id=git_oauth_token,src=$OAUTH_CFG . || exit 1
docker system prune -f || :
docker build --progress=plain --rm --force-rm \
  -t hysds/verdi:${FINAL_TAG} -f docker/Dockerfile \
  --build-arg TAG=${FINAL_TAG} \
  --secret id=git_oauth_token,src=$OAUTH_CFG . || exit 1
docker system prune -f || :
