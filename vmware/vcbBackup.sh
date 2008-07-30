#!/bin/bash

read -p "Enter username to connect to virtcenter: " USER && echo
read -s -p "Enter password for user $USER: " PASS && echo
vcbVmName -h virtcenter -u $USER -p $PASS -s any | grep name:
read -p "Enter the name of the host to be backed up: " NAME && echo
echo vcbMounter -h virtcenter -u $USER -p $PASS  -a name:$NAME -r /mnt/backup/$NAME-$(date +%Y%m%d) -t fullvm -m cos

