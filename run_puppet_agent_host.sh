#!/bin/bash

if [ -z "$1" ]; then
	echo "Please enter hostname"
	exit 1
fi

NAME=$1
CID=$(docker run -d --name $NAME --hostname $NAME -v /etc/hosts:/etc/hosts -e PUPPETMASTER_TCP_HOST=puppet-master -e SSH_KEYS="$(cat ~/.ssh/authorized_keys)" endocode/puppet-agent)
if [ "$?" == "0" ]; then
	IP_ADDRESS=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $CID)
	if [[ $(egrep "$NAME$" /etc/hosts) ]]; then
		sed -i "s/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\s\+\($NAME\)$/$IP_ADDRESS \1/g" /etc/hosts
	else
		echo "$IP_ADDRESS $NAME" | tee -a /etc/hosts
	fi
else
	echo Failed
	exit 1
fi
