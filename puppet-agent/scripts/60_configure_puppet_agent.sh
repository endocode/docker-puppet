#!/bin/bash

# load environment variables
source /etc/container_environment.sh

# configure puppet
PUPPET_AGENT="[agent]
server = ${PUPPETMASTER_TCP_HOST:-puppet-master}
masterport = ${PUPPETMASTER_TCP_PORT:-8140}"

echo "$PUPPET_AGENT" | tee -a /etc/puppet/puppet.conf
