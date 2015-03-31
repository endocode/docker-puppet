#!/bin/bash -e

cut -d ":" -f 1,7 /etc/passwd | while read entry ; do 
    user="$(echo "$entry" | awk -F ":" '{print $1;}')"
    shell="$(echo "$entry" | awk -F ":" '{print $2;}')"
    home="$(getent passwd "$user" | cut -d ":" -f 6)"

    if [ "$shell" == "/bin/bash" ] ; then
        # create $HOME/.ssh/authorized_keys.d
        test -d "$home/.ssh/authorized_keys.d" || mkdir -p "$home/.ssh/authorized_keys.d"
        # create $HOME/.ssh/authorized_keys.d/authorized_keys"
        test -f "$home/.ssh/authorized_keys.d/authorized_keys" || touch "$home/.ssh/authorized_keys.d/authorized_keys"
        # create symlink at $HOME/.ssh/authorized_keys
        ln -fs "$home/.ssh/authorized_keys.d/authorized_keys" "$home/.ssh/authorized_keys"
        # set directory permissions to 0700
        chmod 0700 "$home/.ssh" "$home/.ssh/authorized_keys.d"
        # set file permissions to 0600
        chmod 0600 "$home/.ssh/authorized_keys" "$home/.ssh/authorized_keys.d/authorized_keys"
        # own everything in $HOME/.ssh to $USER
        chown -R "$user:$user" "$home/.ssh"
    fi
done

exit 0
