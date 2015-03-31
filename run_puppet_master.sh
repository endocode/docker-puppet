#!/bin/bash
PREIFIX_DIR=$(pwd)
PUPPET_FILES="puppet_files"
NAME="puppet-master"
CID=$(docker run -d --name $NAME --hostname $NAME -v /etc/hosts:/etc/hosts -v $PREIFIX_DIR/$PUPPET_FILES/ssh-keys:/root/.ssh/authorized_keys.d -v $PREIFIX_DIR/$PUPPET_FILES/manifests:/etc/puppet/manifests -v $PREIFIX_DIR/$PUPPET_FILES/modules:/etc/puppet/modules -v $PREIFIX_DIR/$PUPPET_FILES/ssl-keys:/var/lib/puppet/ssl endocode/puppet-master)
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
