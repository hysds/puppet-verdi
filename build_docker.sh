#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "Enter tag as arg: $0 <tag>"
  echo "e.g.: $0 20170620"
  echo "e.g.: $0 latest"
  exit 1
fi
TAG=$1

docker build --rm --force-rm -t hysds/verdi:${TAG} -f docker/Dockerfile --build-arg RELEASE=${TAG} . || exit 1
docker build --rm --force-rm -t hysds/pge-base:${TAG} -f docker/Dockerfile.pge-base --build-arg RELEASE=${TAG} . || exit 1
docker build --rm --force-rm -t hysds/cuda-pge-base:${TAG} -f docker/Dockerfile.cuda-pge-base --build-arg RELEASE=${TAG} . || exit 1
