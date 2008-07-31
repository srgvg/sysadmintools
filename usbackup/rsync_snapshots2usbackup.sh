#!/bin/bash

usb1=cd361b86-4d33-472c-ba9c-ecb40e05ac89
usb2=56f3ff13-0103-4f19-a333-70c0bf810b08

if [ -e /dev/disk/by-uuid/$usb1 ]
	then 
		usb=$usb1
	elif [ -e /dev/disk/by-uuid/$usb2 ]
	then 
		usb=$usb2 
	else echo No USB disk present ; exit
fi

if $(grep -q $(readlink -f /dev/disk/by-uuid/$usb) /etc/mtab || mount /dev/disk/by-uuid/$usb)
	then
		rsync -aH --delete --numeric-ids --relative /srv/rsnapshot/ /mnt/usbackup/rsnapshot/
	else echo mount usbackup failed at $(date)
fi

if $(umount /dev/disk/by-uuid/$usb)
	then true
	else echo UNmount usbackup failed at $(date)
fi

