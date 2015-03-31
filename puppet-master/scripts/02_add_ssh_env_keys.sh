#!/bin/bash

set -e

# load environment variables
source /etc/container_environment.sh

if [ -z "$SSH_KEYS" ]; then
    # there are no environment keys to add, just get outta here
    exit 0
fi

if [ ! -z "$SSH_USER" ] ; then
    ssh_dir="/home/$SSH_USER/.ssh"
    
    # try writing to the user's home directory
    if [ ! -d "$ssh_dir" ] ; then
        # if there's no SSH directory, create it ; if failed, exit
        mkdir "$ssh_dir" || echo "Unable to create SSH directory at $ssh_dir" && exit 1
        chown $SSH_USER:$SSH_USER
    fi
else
    # assume we're root
    SSH_USER="root"
    ssh_dir="/root/.ssh"
fi

# create authorized_keys if not present
test -f $ssh_dir/authorized_keys || touch $ssh_dir/authorized_keys

# truncate the file, start from scratch
: > $ssh_dir/authorized_keys

# add the keys
echo "$SSH_KEYS" | while read key ; do 
    keyfile="$(tempfile)"
    echo "$key" >> "$keyfile"
    ssh-keygen -lf "$keyfile"
    rm "$keyfile"
    echo "$key" >> "$ssh_dir/authorized_keys"
done

# chown the file
chown $SSH_USER:$SSH_USER "$ssh_dir/authorized_keys"

# set file permissions
chmod 0600 "$ssh_dir/authorized_keys"

# exit clean
exit 0
