# syntax = docker/dockerfile:1.0-experimental
ARG TAG=HC-522
FROM hysds/pge-base:${TAG}

MAINTAINER Gerald Manipon (pymonger) "pymonger@gmail.com"
LABEL description="HySDS verdi image"

# link configs
RUN set -ex \
 && ln -sf /home/ops/verdi/etc/celeryconfig.py /home/ops/verdi/ops/hysds/celeryconfig.py

# set default supervisord conf and copy includes
COPY --chown=ops:ops docker/supervisord.conf /home/ops/verdi/etc/supervisord.conf
COPY --chown=ops:ops docker/conf.d /home/ops/verdi/etc/conf.d

# set entrypoint
COPY docker/entrypoint* /
ENTRYPOINT ["/entrypoint-verdi.sh"]
EXPOSE 22 80 443 8085 9001
CMD ["supervisord"]
