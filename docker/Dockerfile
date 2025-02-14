# syntax = docker/dockerfile:1.0-experimental
ARG TAG=HC-562
FROM hysds/pge-base:${TAG}

MAINTAINER Gerald Manipon (pymonger) "pymonger@gmail.com"
LABEL description="HySDS verdi image"

# link configs
RUN set -ex \
 && ln -sf $HOME/verdi/etc/celeryconfig.py $HOME/verdi/ops/hysds/celeryconfig.py \
 && cd $HOME/verdi/ops \
 && rm -rf hysds_commons \
 && git clone https://github.com/hysds/hysds_commons.git \
 && cd hysds_commons \
 && git checkout -b HC-562 origin/HC-562 \
 && pip install -e .

# set default supervisord conf and copy includes
COPY --chown=root:root docker/supervisord.conf $HOME/verdi/etc/supervisord.conf
COPY --chown=root:root docker/conf.d $HOME/verdi/etc/conf.d

# set entrypoint
COPY docker/entrypoint* /
ENTRYPOINT ["/entrypoint-verdi.sh"]
EXPOSE 22 80 443 8085 9001
CMD ["supervisord"]
