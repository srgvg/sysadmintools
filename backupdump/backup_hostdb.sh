#!/bin/sh
##############################################################################
# backup_hostdb.sh
#
# by Serge van Ginderachter <serge@vanginderachter.be>
# http://www.vanginderachter.be http://www.ginsys.be
#
# mysql database enumeration code based on a script 
# by Nathan Rosenquist <nathan@rsnapshot.org>
# http://www.rsnapshot.org/
#
# This is a simple shell script to backup different databases on a Debian 
# based host. It can be used as a standalone script, but the assumption is 
# that this will be invoked from rsnapshot. Also, since it will run unattended
# so the user that runs rsnapshot (probably root) should have proper access to 
# the databases, especially in case of mysql a .my.cnf file in the (remote) 
# user home directory that contains the password will be necessary.
#
# This script simply dumps files into the current working directory.
# rsnapshot handles everything else.
#
##############################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################

##############################################################################
# parse options
##############################################################################

hflag=
lflag=
sflag=
mflag=
dflag=
zflag=
	while getopts 'h:ls:mdz' OPTION
	do
	  case $OPTION in
	  h)	hflag=1
	  		hval="$OPTARG"
			;;
	  l)	lflag=1
			;;
	  s)	sflag=1
	  		if [ -z "$OPTARG" ]
	  		then
	  			svnrepopaths="/var/lib/svn/"
	  		else
	  			svnrepopaths="$OPTARG"
	  		fi
			;;
	  m)	mflag=1
			;;
	  d)	dflag=1
			;;
	  z)	zflag=1
			;;
	  ?)	printf "Usage: [-h [user@]host] [-l] [-s [\"<svn repositories paths>\"]] [-m] [-d] \n -h     remote host \n -l     dump openldap \n -m     dump mysql databases \n -d     dump dpkg selections \n -s     dump svn repositories with arguments for one or more repository basepaths - can be empty string \n" $(basename $0)"\n -z     zip the dumpfiles" >&2
			exit 2
			;;
	  esac
	done


##############################################################################
# variables can be adapted to customize the script
##############################################################################
REMOTEHOST="$hval"


# add paths separated by spaces - path with spaces will break this


##############################################################################
# these variables should not be changed
##############################################################################
if [ ! "$REMOTEHOST" = "" ]; then REMOTECOMMAND="ssh $REMOTEHOST"; fi

##############################################################################
# dump dpkg selections
##############################################################################
if [ "$dflag" ]
then
	dpkgdumpfile=dpkg-selections.txt
	$REMOTECOMMAND dpkg --get-selections > $dpkgdumpfile
	dumpedfiles=1
else
	dpkgdumpfile=
fi
##############################################################################
# mysql backup
##############################################################################
if [ "$mflag" ]
then
	# check MYSQL data directory
	MYSQL_DATA_DIR=$( $REMOTECOMMAND grep datadir /etc/mysql/my.cnf | sed -e "s/.*\=//" -e "s/^\ //" )
	# enumerate the databases
	DATABASES=$( $REMOTECOMMAND find $MYSQL_DATA_DIR/ -type d | xargs -n1 basename)
	# dump backups
	for db in $DATABASES
	    do
	    dumpfile="$db.sql"
	    $REMOTECOMMAND mysqldump $db $TABLES --opt --lock-all-tables --add-drop-database --add-drop-table --add-locks --allow-keywords  -q > $dumpfile
	    sqldumpfile="$sqldumpfile $dumpfile"
	done
	dumpedfiles=1
else
	sqldumpfile=

fi
##############################################################################
# svn backup
##############################################################################
if [ "$sflag" ]
then
	for repo in $($REMOTECOMMAND find $svnrepopaths -mindepth 1 -maxdepth 1 -type d )
	        do 
	        dumpfile="./$(basename $repo).svn"
	        $REMOTECOMMAND svnadmin -q dump $repo >$dumpfile
		svndumpfile="$svndumpfile $dumpfile"
        done
	dumpedfiles=1
else
	svndumpfile=
fi	
##############################################################################
# openldap backup
##############################################################################
if [ "$lflag" ]
then
	ldapdumpfile=ldap.ldif
	$REMOTECOMMAND invoke-rc.d slapd stop >/dev/null
	$REMOTECOMMAND slapcat > $ldapdumpfile
	$REMOTECOMMAND invoke-rc.d slapd start >/dev/null
	dumpedfiles=1
else
	ldapdumpfile=
fi
##############################################################################
# make sure the backups readable only by the owner
##############################################################################
if [ "$dumpedfiles" ]
then
	/bin/chmod 600 $dpkgdumpfile $ldapdumpfile $sqldumpfile $svndumpfile
fi
##############################################################################
# zip the files
##############################################################################
if [ "$zflag" ]
then
	/bin/gzip $dpkgdumpfile $ldapdumpfile $sqldumpfile $svndumpfile
fi
##############################################################################

