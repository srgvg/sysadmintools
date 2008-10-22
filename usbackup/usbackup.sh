#!/bin/bash

##################################################################
### Parameter defaults #####
# sum up UUID's for different usb mount points, space separated
uuids="40f27d2b-ec3b-48c7-a14a-c660563ee940 69b98ce2-dd00-411a-9d63-2083a18734bf"
mountpoint="/mnt/usbackup"
snapshot_root="/srv/rsnapshot"
# verbosity for STDOUT only, errors are allways send to STDERR; 
verbose="0"
# internal parameters
config="usbackup.conf"
MESSAGE_PREFIX="USBACKUP"
log_tag=$0
log_facility=syslog
count=0

##################################################################

say() {
        MESSAGE="$1"
        TIMESTAMP=$(date +"%F %T")
        if [ $verbose != "0" ] ; then echo -e "$TIMESTAMP $MESSAGE_PREFIX $MESSAGE" ; fi
        logger -t $log_tag -p $log_facility.info "$MESSAGE"
        }

error ()  {
        MESSAGE="$1"
        TIMESTAMP=$(date +"%F %T")
        echo -e $TIMESTAMP $MESSAGE >&2
        logger -t $log_tag -p $log_facility.err "$MESSAGE"
        }

if   [ -f $(dirname $0)/$config ]
then source $(dirname $0)/$config
elif [ -f /etc/$config ] 
then source /etc/$config
else error "Please create  $(dirname $0)/$config OR /etc/$config"; exit
fi

for uuid in $uuids 
	do
		if [ -e /dev/disk/by-uuid/$uuid ]
			then usb=$uuid ; let count=count+1
		fi
	done

case $count in 
	0)
		error "Error: no defined disk available."
		exit 1
		;;
	1)
		true
		;;
	*)
		error "Error: more than one disk available."
		exit 1
		;;
esac

# $usb holds the uuid of the (last) disk we want to mount
# we check if it is already mounted, and if not, we mount it

say "Mounting disk /dev/disk/by-uuid/$usb = $(readlink -f /dev/disk/by-uuid/$usb)"
if $(grep -q $(readlink -f /dev/disk/by-uuid/$usb) /etc/mtab )
then error "Disk $(readlink -f /dev/disk/by-uuid/$usb) was already mounted."
elif $(mount /dev/disk/by-uuid/$usb $mountpoint)
then say "Disk $(readlink -f /dev/disk/by-uuid/$usb) was mounted."
else error "Disk $(readlink -f /dev/disk/by-uuid/$usb) failed to mount at $(date)." ; exit 1
fi

## execute command on mounted disk here
eval $* && say "Command $* -- returns success" || error "Command returns error"

# to sync rsnapshots the command could be
# rsync -aH --delete --numeric-ids --relative $snapshot_root/ $mountpoint/rsnapshot/


## umount afterwards
if $(umount /dev/disk/by-uuid/$usb)
        then say "Disk $(readlink -f /dev/disk/by-uuid/$usb) was unmounted."
        else error "Unmounting disk failed at $(date)."; exit 1
fi

