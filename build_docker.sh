#!/bin/bash
docker build --rm --force-rm -t hysds/verdi:latest -f docker/Dockerfile .
docker build --rm --force-rm -t hysds/pge-base:latest -f docker/Dockerfile.pge-base .
