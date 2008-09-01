#!/bin/sh
source /etc/profile

##############################################################################
# backup_slapd.sh
#
# by Serge van Ginderachter <serge@vanginderachter.be>
# http://www.vanginderachter.be
#
# This is a simple shell script to backup a OpenLDAP database with rsnapshot.
#
# This script simply needs to dump a file into the current working directory.
# rsnapshot handles everything else.
##############################################################################

# backup the database
/etc/init.d/slapd stop
slapcat > ldap.ldif
/etc/init.d/slapd start 

# make the backup readable only by root
/bin/chmod 600 ldap.ldif
