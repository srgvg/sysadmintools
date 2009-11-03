#! /bin/sh

# Add following line to /etc/zabbix/zabbix_agentd.conf
# UserParameter=mdcheck[*],mdcheck.sh $1

md=$1

if [ ! -b /dev/${md} ]
then
        # not a device or device does not exist
        status="-1"
else
        mdadmoutput=$(/sbin/mdadm --detail -t /dev/${md} 2>&1)
        # 0      The array is functioning normally.
        # 1      The array has at least one failed device.
        # 2      The array has multiple failed devices such that it is unusable.
        # 4      There was an error while trying to get information about the device.
        status=$?
fi
if      [ "$status" = 0 ] && \
	[ $(cat /sys/block/${md}/md/degraded) = 1 ] && \
        $( echo $mdadmoutput | grep -e State.*resyncing -e State.*recovering >/dev/null )
then
        status=3
fi
echo $status
exit $status


