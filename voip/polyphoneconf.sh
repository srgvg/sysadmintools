#!/bin/bash
# Script to configure Polycom phones
# by Chris Mason masonc@masonc.com
#
# Usage: ./phoneconf phonemacaddress extention username secret context
#
# Variables to configure
if [ -z $PHONEDIR ]
	then PHONEDIR=~/asterisk
fi
#
# See how we were called.
case "$1" in
  help)
	echo "Usage: ./phoneconf [config|help] phonemacaddress extention username secret context"
        ;;
  config)
  	echo 'MAC: ' ${2}
  	echo 'EXT: ' ${3}
  	echo 'USER: ' ${4}
  	echo 'SECRET: ' ${5}
  	echo 'CONTEXT: ' ${6}

	# Changedir to directory where config files are kept
	mkdir -p $PHONEDIR
	cd $PHONEDIR

	#
	# Master file section
	#

	# Delete old file
	#

	if [ -f $2.cfg ] ; then
	 	rm $2.cfg
	fi
	
	if [ -f $2-phone.cfg ] ; then
	 	rm $2-phone.cfg
	fi

	# Output master file

	echo '<?xml version="1.0" encoding="UTF-8"?>' >$2.cfg
	echo '<APPLICATION APP_FILE_PATH="sip.ld"
       		CONFIG_FILES="'$2'-phone.cfg, sip.cfg, ipmid.cfg "
       		LOG_FILE_DIRECTORY="log/" MISC_FILES="" /> ' >>$2.cfg

	# Registrations file
	# 
	# Delete old file
	#

	if [ -f $2-phone.cfg ] ; then
	 	rm $1-phone.cfg
	fi

	# Output registrations file

	echo '<?xml version="1.0" encoding="UTF-8"?>' >> $2-phone.cfg
	echo '	<PHONE_CONFIG>
		<phone1>
  		<reg 	reg.1.address="'$3'" 
       			reg.1.auth.password="'$4'"
       			reg.1.auth.userId="'$3'" 
       			reg.1.displayName="'$3'" 
       			reg.1.label="'$3'"
       			reg.1.type="private" 
       			reg.1.server.1.expires="3600" /> ' >>  $2-phone.cfg

	echo '	<msg msg.bypassInstantMessage="1">
    		<mwi msg.mwi.1.callBack="8500" msg.mwi.1.callBackMode="contact"
         	msg.mwi.1.subscribe="" />
  		</msg>
	</phone1>
	</PHONE_CONFIG>" '  >> $2-phone.cfg
	#
	echo ' ' >> $PHONEDIR/sip.conf

	echo '['$3']' >> $PHONEDIR/sip.conf

	echo 'type=friend
	host=dynamic
	dtmfmode=rfc2833
	username='$3'
	secret='$4'
	canreinvite=no
	reinvite=no
	callerid="'$6'" <'$3'>
	mailbox='$3'
	notifymimetype=text/plain
	disallow=all
	allow=ulaw
	qualify=yes
	context='$6 >> $PHONEDIR/sip.conf

	echo $3' => 1234,'$5 >> $PHONEDIR/voicemail.conf

	#service asterisk reload

	echo 'Done'
	;;
  *)
        echo $"Usage: $prog {[config|help] phonemacaddress extention username secret context"
	exit 1
esac
exit $RETVAL


