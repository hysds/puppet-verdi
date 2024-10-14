# syntax = docker/dockerfile:1.0-experimental
ARG TAG=latest
FROM hysds/pge-base:${TAG}

MAINTAINER Gerald Manipon (pymonger) "pymonger@gmail.com"
LABEL description="HySDS verdi image"

# link configs
RUN set -ex \
 && ln -sf $HOME/verdi/etc/celeryconfig.py $HOME/verdi/ops/hysds/celeryconfig.py

# set default supervisord conf and copy includes
COPY --chown=root:root docker/supervisord.conf $HOME/verdi/etc/supervisord.conf
COPY --chown=root:root docker/conf.d $HOME/verdi/etc/conf.d

# set entrypoint
COPY docker/entrypoint* /
ENTRYPOINT ["/entrypoint-verdi.sh"]
EXPOSE 22 80 443 8085 9001
CMD ["supervisord"]
