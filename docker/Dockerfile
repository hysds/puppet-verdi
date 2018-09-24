FROM hysds/dev:latest

# git url to hysds dev puppet module
ENV GIT_URL https://github.com/hysds/puppet-verdi/raw/docker/install.sh

# add latest repo version to invalidate cache
ADD https://api.github.com/repos/hysds/puppet-verdi/git/refs/heads/docker version.json

# provision via puppet
RUN set -ex \
 && sudo yum update -y \
 && sudo curl -skL ${GIT_URL} > /tmp/install.sh \
 && sudo chmod 755 /tmp/install.sh \
 && sudo /tmp/install.sh \
 && sudo rm -rf /etc/puppet/modules/* /mnt/swapfile \
 && sudo yum clean all \
 && sudo rm -f /tmp/install.sh \
 && sudo rm -rf /var/cache/yum \
 && cd $HOME \
 && ./install_hysds.sh \
 && rm -rf $HOME/verdi/ops/*/.git* \
 && rm -rf $HOME/.cache


FROM hysds/base:latest

MAINTAINER Gerald Manipon (pymonger) "pymonger@gmail.com"
LABEL description="HySDS verdi image"

# git url to hysds dev puppet module
ENV GIT_URL https://github.com/hysds/puppet-verdi/raw/docker/install.sh

# add latest repo version to invalidate cache
ADD https://api.github.com/repos/hysds/puppet-verdi/git/refs/heads/docker version.json

# provision via puppet
RUN set -ex \
 && sudo yum update -y \
 && sudo curl -skL ${GIT_URL} > /tmp/install.sh \
 && sudo chmod 755 /tmp/install.sh \
 && sudo /tmp/install.sh \
 && sudo rm -rf /etc/puppet/modules/* /mnt/swapfile \
 && sudo yum clean all \
 && sudo rm -f /tmp/install.sh \
 && sudo rm -rf /var/cache/yum

# copy ops home
COPY --chown=ops:ops --from=0 /home/ops /home/ops

# link celeryconfig
RUN set -ex \
 && ln -sf /home/ops/verdi/etc/celeryconfig.py /home/ops/verdi/ops/hysds/celeryconfig.py

# set entrypoint
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 80 443 8085 9001
CMD ["supervisord"]
