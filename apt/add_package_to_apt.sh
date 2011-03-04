#!/bin/bash

DEFAULT="hardy"

usage()
{
	echo "usage: add_package_to_apt.sh [REPO] package.deb"
	echo "REPO: name of repository or all (optional)"
	echo "	- hardy (default)"
	echo "	- intrepid"
	echo "	- jaunty"
	echo "	- lenny"
}

# repo, file
add_file_to_repo()
{
	if [ ! -f $2 ]; then
		echo "File $2 doesn't exist"
		exit 1
	fi
	rsync -v -e "ssh -l vpan -i ./vpan_repository_key" $2 vpan.net:/tmp/
	FILENAME=`basename $2`
	ssh -l vpan -i ./vpan_repository_key vpan.net "reprepro -Vb /var/www/packages -C main includedeb $1 /tmp/$FILENAME"
}


if [ $# == 0 ]; then
  usage
  exit 1;
fi

if [ $# == 1 ]; then
  add_file_to_repo $DEFAULT $1
fi

if [ $# == 2 ]; then
	case "$1" in
		all)
			add_file_to_repo hardy $2
			add_file_to_repo intrepid $2
			add_file_to_repo jaunty $2
			add_file_to_repo lenny $2
			;;
  	hardy)
			add_file_to_repo hardy $2
  		;;
  	intrepid)
			add_file_to_repo intrepid $2
  		;;
  	jaunty)
			add_file_to_repo jaunty $2
  		;;
  	lenny)
			add_file_to_repo lenny $2
  		;;
  	*)
  		usage
  		exit 1
  esac
fi



exit $RETVAL
