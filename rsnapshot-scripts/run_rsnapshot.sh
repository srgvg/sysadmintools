#!/bin/sh
set -x

checkdir=/var/lib/rsnapshot/
instance=$1
bigintervals="monthly weekly daily"
smallestinterval="hourly"

if [ "$instance" = "0" -o "$instance" = "1" ]
then true 
else	echo First parameter should be 0 or 1
	exit
fi

mkdir -p ${checkdir} && touch ${checkdir}${smallestinterval}.${instance}
for interval in ${bigintervals} ${smallestinterval}
do	if [ -f ${checkdir}${interval}.${instance} ]
	then	/usr/bin/ionice -c 2 -n 7 /usr/local/sbin/usbackup${instance}.sh /usr/bin/rsnapshot -c /etc/rsnapshot${instance}.conf ${interval} && rm ${checkdir}${interval}.${instance}
	fi
done

