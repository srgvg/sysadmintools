#!/bin/sh

RSNAPSHOT_CLIENT_USER=rsnapshot
RSNAPSHOT_HOME=/var/lib/rsnapshot
BACKUPSERVERIP=""
BACKUPSERVERSSHPUBKEY=""
rsnapshotmysqluser="rsnapshot"
rsnapshotmysqlpassword="readonly"

if [ -f validate-rsnapshot ] 
then	rm validate-rsnapshot 
fi
wget $BACKUPSERVERIP/rsnapshot-client/validate-rsnapshot
cp validate-rsnapshot /usr/local/bin
chmod 755 /usr/local/bin/validate-rsnapshot

[ -x "$(which rsync)" -o -x "$(which sudo)" ] || apt-get update && apt-get install rsync sudo

umask 077

grep $RSNAPSHOT_CLIENT_USER /etc/passwd >/dev/null && userdel -r $RSNAPSHOT_CLIENT_USER
adduser --home $RSNAPSHOT_HOME --disabled-password --gecos "Rsnapshot backup user" $RSNAPSHOT_CLIENT_USER

test -d $RSNAPSHOT_HOME/.ssh || mkdir $RSNAPSHOT_HOME/.ssh
cat >> $RSNAPSHOT_HOME/.ssh/authorized_keys << EOF
from="$BACKUPSERVERIP",command="validate-rsnapshot" $BACKUPSERVERSSHPUBKEY
EOF

sql=$(mktemp)
cat > $sql << EOF
GRANT SHOW DATABASES, SHOW VIEW, SELECT, LOCK TABLES, RELOAD ON *.* to $rsnapshotmysqluser@localhost IDENTIFIED BY '$rsnapshotmysqlpassword'; 
FLUSH PRIVILEGES;
EOF
if [ -x "$(which mysql)" ]
then	echo Set a mysql backup user
	cat $sql | mysql -u root -p || echo failed executing sql query 
else	echo No sql client detected. If you want to allow rsnaoshot to backup mysql, please execute this sql query:
	echo "########################################"
	cat $sql
	echo "########################################"
fi

echo ; echo

cat >> $RSNAPSHOT_HOME/.my.cnf << EOF
[client]
user=rsnapshot
password=readonly
EOF

chown rsnapshot:rsnapshot $RSNAPSHOT_HOME/.ssh -R
chown rsnapshot:rsnapshot $RSNAPSHOT_HOME/.my.cnf -R

grep rsnapshot /etc/sudoers >/dev/null || cat >> /etc/sudoers << EOF

# backup rsnapshot
rsnapshot ALL=NOPASSWD: /usr/bin/rsync

EOF

echo ; echo

echo "Be sure to check that the rsnapshot user is allowed to log in through SSH, as some hosts are setup with AllowUsers in sshd_config."

echo ; echo


rm $sql

