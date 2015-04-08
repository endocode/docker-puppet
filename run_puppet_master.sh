#!/bin/bash
DNSMASQ_HOSTS=/etc/hosts.dnsmasq.conf
DNSMASQ_PID=/var/run/dnsmasq/dnsmasq.pid
PREFIX_DIR=$(pwd)
PUPPET_FILES="puppet_files"
NAME="puppet-master"
CID=$(docker run -d --name $NAME --hostname $NAME -v $PREFIX_DIR/$PUPPET_FILES/ssh-keys:/root/.ssh/authorized_keys.d -v $PREFIX_DIR/$PUPPET_FILES/manifests:/etc/puppet/manifests -v $PREFIX_DIR/$PUPPET_FILES/modules:/etc/puppet/modules -v $PREFIX_DIR/$PUPPET_FILES/ssl-keys:/var/lib/puppet/ssl endocode/puppet-master)

if [ "$?" == "0" ]; then
	if [ ! -f $DNSMASQ_HOSTS ]; then
		touch $DNSMASQ_HOSTS
	fi
	IP_ADDRESS=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $CID)
	if [[ $(egrep "$NAME$" $DNSMASQ_HOSTS) ]]; then
		sed -i "s/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\s\+\($NAME\)$/$IP_ADDRESS \1/g" $DNSMASQ_HOSTS
	else
		echo "$IP_ADDRESS $NAME" | tee -a $DNSMASQ_HOSTS
	fi
	kill -HUP $(cat $DNSMASQ_PID)
else
	echo Failed
	exit 1
fi
