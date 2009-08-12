#!/bin/sh


#Edit these values to match you environment
#####################################
#The datastore to backup to
backupDataStore=<backupDataStore>

#The directory on the above datastore to backup to(the default is mm-dd-yyyy)
backupDirectory=$(date +%m-%d-%Y)

#The list of virtual machine names(separated by a space) to backup 
vmsToBackup="VM1 VM2 VM3"

#The amount of time to wait for the snapshot to complete, some systems are slower than others and snapshot operations may take longer to complete
waitTime=40s 
#####################################

startTime=$(date)
echo Backup start time: $startTime

echo Creating backup directory /vmfs/volumes/$backupDataStore/$backupDirectory
mkdir -p /vmfs/volumes/$backupDataStore/$backupDirectory

echo Backing up ESXi host configuration...
vim-cmd hostsvc/firmware/backup_config
cp /scratch/downloads/*.tgz /vmfs/volumes/$backupDataStore/$backupDirectory/

for vm in $vmsToBackup;do
	vmName=$vm
	vmIdAndConfigPath=$( vim-cmd vmsvc/getallvms | awk '{ if ($2 == vmname) print $1 ";" $3 $4}' vmname=$vm)
	vmId=${vmIdAndConfigPath%;*}

	if [ "$vmId" != "" ]; then
	
		echo Backing up virtual machine: $vmName 
		

		echo Backing up the virtual machines configuration...
		vmConfigurationFilePath=$(echo ${vmIdAndConfigPath#*;} | sed -e 's/\[\(.*\)\]\(.*\)/\1;\2/') 
		vmConfigurationSourceDataStore=${vmConfigurationFilePath%;*}
		vmConfigurationFile=${vmConfigurationFilePath#*;}
		echo Making directory /vmfs/volumes/$backupDataStore/$backupDirectory/${vmConfigurationFile%/*}
		mkdir -p /vmfs/volumes/$backupDataStore/$backupDirectory/${vmConfigurationFile%/*}
		echo Copying /vmfs/volumes/$vmConfigurationSourceDataStore/$vmConfigurationFile to /vmfs/volumes/$backupDataStore/$backupDirectory/$vmConfigurationFile		
		cp /vmfs/volumes/$vmConfigurationSourceDataStore/$vmConfigurationFile /vmfs/volumes/$backupDataStore/$backupDirectory/$vmConfigurationFile				

		echo Taking the snapshot...
		vim-cmd vmsvc/snapshot.create $vmId "Backup"

		echo Waiting $waitTime for the snapshot to complete...
		sleep $waitTime
	
		echo Getting diskFile list...
		vmDiskFilePaths=$(vim-cmd vmsvc/get.filelayout $vmId | grep -i snapshotFile -A2000 | sed -n -e 's/\"\[\(.*\)\]\s\(.*\.vmdk\)\"\,/\1;\2/pg')
		echo Found $(echo $vmDiskFilePaths | wc -l) disk file\(s\)...
		for vmDiskFilePath in $vmDiskFilePaths; do
			vmDiskFileSourceDataStore=${vmDiskFilePath%;*}
			vmDiskFile=${vmDiskFilePath#*;}

			if [ -e /vmfs/volumes/$vmDiskFileSourceDataStore/$vmDiskFile ]; then
				if [ ! -d /vmfs/volumes/$backupDataStore/$backupDirectory/${vmDiskFile%/*} ]; then
					mkdir -p /vmfs/volumes/$backupDataStore/$backupDirectory/${vmDiskFile%/*}
				fi

				echo Cloning /vmfs/volumes/$vmDiskFileSourceDataStore/$vmDiskFile to /vmfs/volumes/$backupDataStore/$backupDirectory/$vmDiskFile
				vmkfstools -d 2gbsparse -i /vmfs/volumes/$vmDiskFileSourceDataStore/$vmDiskFile /vmfs/volumes/$backupDataStore/$backupDirectory/$vmDiskFile
			fi
		done
		
		echo Removing the snapshot...
		vim-cmd vmsvc/snapshot.removeall $vmId

	else
		echo ERROR: Could not get an id for $vmName
	fi
done

endTime=$(date)
echo Backup end time: $endTime
#echo Elapsed time: $(($startTime - $endTime))


