#!/bin/sh

##############################################################################
# backup_mysql.sh
#
# by Nathan Rosenquist <nathan@rsnapshot.org>
# http://www.rsnapshot.org/
#
# This is a simple shell script to backup a MySQL database with rsnapshot.
#
# The assumption is that this will be invoked from rsnapshot. Also, since it
# will run unattended, the user that runs rsnapshot (probably root) should have
# a .my.cnf file in their home directory that contains the password for the
# MySQL root user.
#
# This script simply needs to dump a file into the current working directory.
# rsnapshot handles everything else.
##############################################################################

MYSQL_DATA_DIR=$(grep datadir /etc/mysql/my.cnf | sed -e "s/.*\=//")
rtDB="rtdb"
rtMainTables="ACL Attributes CachedGroupMembers CustomFieldValues CustomFields GroupMembers \
Groups Links ObjectCustomFieldValues ObjectCustomFields Principals Queues ScripActions \
ScripConditions Scrips Templates Tickets Transactions Users sessions"


# backup the database
#/usr/bin/mysqldump -uroot --all-databases > mysqldump_all_databases.sql

for db in $(find $MYSQL_DATA_DIR/ -type d | sed -e "s/\/var\/lib\/mysql\///");
    do
    if [ $db == $rtDB ]
	then TABLES="$rtMainTables"
	else TABLES=""
    fi
    mysqldump -uroot $db --opt $TABLES -a --lock-all-tables --add-drop-table --add-locks --allow-keywords  -q > $db.sql

    # make the backup readable only by root
    /bin/chmod 600 $db.sql
done

# do the $rtDB Attachment backup
mysqldump $rtDB --opt --default-character-set=binary Attachments -a --add-drop-table --allow-keywords --add-locks -q > $rtDB-attachments.sql

# make the backup readable only by root
chown root:root *.sql
/bin/chmod 600 *.sql


