
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

REMOTEHOST="$1"
if [ ! $REMOTEHOST = "" ]; then REMOTECOMMAND="ssh $REMOTEHOST"; fi

MYSQL_DATA_DIR=$( $REMOTECOMMAND grep datadir /etc/mysql/my.cnf | sed -e "s/.*\=//" -e "s/^\ //" )
#rtDB="rtdb"
#rtMainTables="ACL Attributes CachedGroupMembers CustomFieldValues CustomFields GroupMembers \
#Groups Links ObjectCustomFieldValues ObjectCustomFields Principals Queues ScripActions \
#ScripConditions Scrips Templates Tickets Transactions Users sessions"


# backup the databases

DATABASES=$( $REMOTECOMMAND find $MYSQL_DATA_DIR/ -type d | xargs -n1 basename)
echo $DATABASES

for db in $DATABASES
    do
echo Backup = $db
#    if [ $db == $rtDB ]
#       then TABLES="$rtMainTables"
#       # do the $rtDB Attachment backup
#       $REMOTECOMMAND mysqldump $rtDB Attachments --opt --default-character-set=binary --add-drop-database --add-drop-table --allow-keywords --add-locks -q > $rtDB-attachmentssql
#       else TABLES=""
#    fi
    $REMOTECOMMAND mysqldump $db $TABLES --opt --lock-all-tables --add-drop-database --add-drop-table --add-locks --allow-keywords  -q > $db.sql

    # make the backup readable only by root
    /bin/chmod 600 $db.sql
done


# make the backup readable only by root
chown root:root *.sql
/bin/chmod 600 *.sql


