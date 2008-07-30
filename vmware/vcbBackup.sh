#!/bin/bash

read -p "Enter username to connect to virtcenter: " USER && echo
read -s -p "Enter password for user $USER: " PASS && echo
vcbVmName -h virtcenter -u $USER -p $PASS -s any | grep name: || exit
read -p "Enter the names of the hosts to be backed up, separated by a space: " NAME && echo
for HOST in $(echo $NAME)
        do vcbMounter -h virtcenter -u $USER -p $PASS  -a name:$HOST -r /mnt/backup/$HOST-$(date +%Y%m%d) -t fullvm -m cos
        done

