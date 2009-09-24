#! /bin/sh

# Add following line to /etc/zabbix/zabbix_agentd.conf
# UserParameter=mdcheck[*],mdcheck.sh $1

md=$1

if [ ! -b /dev/${md} ]
then
        # not a device or device does not exist
        status="-1"
else
        /sbin/mdadm --detail -t /dev/${md} >/dev/null 2>&1
	# 0      The array is functioning normally.
	# 1      The array has at least one failed device.
	# 2      The array has multiple failed devices such that it is unusable.
	# 4      There was an error while trying to get information about the device.
        status=$?
fi
echo $status
exit $status

