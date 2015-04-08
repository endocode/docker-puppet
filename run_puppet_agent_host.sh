#!/bin/bash

if [ -z "$1" ]; then
	echo "Please enter hostname"
	exit 1
fi

DNSMASQ_HOSTS=/etc/hosts.dnsmasq.conf
DNSMASQ_PID=/var/run/dnsmasq/dnsmasq.pid
NAME=$1
CID=$(docker run -d --name $NAME --hostname $NAME -e PUPPETMASTER_TCP_HOST=puppet-master -e SSH_KEYS="$(cat ~/.ssh/authorized_keys)" endocode/puppet-agent)

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
