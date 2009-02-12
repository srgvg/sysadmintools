
##############################################################################
# backup_dpkgsel.sh
#
# This script simply needs to dump a file into the current working directory.
# rsnapshot handles everything else.
##############################################################################

dumpfile=dpkg-selections.txt

REMOTEHOST="$1"
if [ ! $REMOTEHOST = "" ]; then REMOTECOMMAND="ssh $REMOTEHOST"; fi

# dump dpkg selections

$REMOTECOMMAND dpkg --get-selections > $dumpfile

# make the backup readable only by root
chown root:root $dumpfile
/bin/chmod 600 $dumpfile


