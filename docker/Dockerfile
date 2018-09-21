FROM hysds/dev:latest

# git url to hysds dev puppet module
ENV GIT_URL https://github.com/hysds/puppet-verdi/raw/docker-lite/install.sh

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
 && ./install_hysds.sh


FROM hysds/base:latest

MAINTAINER Gerald Manipon (pymonger) "pymonger@gmail.com"
LABEL description "Base Verdi image for HySDS"

# git url to hysds dev puppet module
ENV GIT_URL https://github.com/hysds/puppet-verdi/raw/docker-lite/install.sh

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

COPY --from=0 /home/ops /home/ops
