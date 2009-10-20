#!/bin/sh
#set -x

# Exit codes
#  1	bad parameter syntax
#  2	failed to initialize


################################################################################
# parameters

KERNEL=linux-2.6.31.tar.bz2
KERNELCONF=config-2.6.31-14-server
WAVES=" DeadWhiteGuys1.wav  mrsandman.wav  starthal.wav  vivaldi.wav "
TESTDIR=/var/lib/libvirt/images/bonnietest
TESTUSER=atlantis
DBENCHNUMCLIENT=10

################################################################################
# initialization

MYIP=$( ip -f inet route show dev eth0 | grep src | awk '{ print $7 }' )
BASEDIR=$(cd $(dirname $0); pwd)
FILESDIR=$BASEDIR/files
WORKDIR=$BASEDIR/work
KERNELDIR=$WORKDIR/kernel
LAMEDIR=$WORKDIR/lame
LOGDIR=$LOGBASEDIR/$TIMESTAMP
LOGBASEDIR=$WORKDIR/logs/$(hostname)-${MYIP}
TIMESTAMP=$(date +%Y%m%d%H%M)

uname -a | grep x86_64 >/dev/null && mbandwidth="./bandwith64" || mbandwidth="./bandwith32"
################################################################################
init_env() {
cd $BASEDIR
mkdir -p $LOGDIR $KERNELDIR $LAMEDIR $TESTDIR
chmod 777 $TESTDIR
[ -L $LOGBASEDIR/latest ] && rm $LOGBASEDIR/latest || ln -s $TIMESTAMP $LOGBASEDIR/latest

# install dependencies
	[ -x "$(which ssh)" ] 		|| packages=$packages" openssh-client"
	[ -x "$(which bonnie++)" ] 	|| packages=$packages" bonnie++"
	[ -x "$(which iperf)" ] 	|| packages=$packages" iperf"
	[ -x "$(which lame)" ] 		|| packages=$packages" lame"
	[ -x "$(which bzip2)" ] 	|| packages=$packages" bzip2"
	[ -x "$(which lshw)" ] 		|| packages=$packages" lshw"
	[ -x "$(which dmidecode)" ] 	|| packages=$packages" dmidecode"
	[ -x "$(which gcc)" ] 		|| packages=$packages" gcc"
	[ -x "$(which dbench)" ] 	|| packages=$packages" dbench"
	[ -x "$(which netperf)" ] 	|| packages=$packages" netperf"
#	[ -x  ] 			|| packages=$packages" "
if [ ! -z "$packages" ]
then #install packages
	if [ -x $(which aptitude) ]
	then #debian or ubuntu
		aptitude update && aptitude upgrade 
		aptitude install $packages
	elif [ -x $( which yum ) ]
	then #centos or fedora
		yum update
		echo "Please check for missing packages:"
		yum install $packages
		echo "Please check for missing packages!"
	else
		echo Failed to detect distribution, please make sure \
		necessary packages are installed. 
		exit 1
	fi
fi
}
################################################################################
init_srv_env() {
cd $BASEDIR
mkdir -p $LOGDIR 

# install dependencies
	[ -x "$(which iperf)" ] 	|| packages=$packages" iperf"
	[ -x "$(which dbench)" ] 	|| packages=$packages" dbench"
	[ -x "$(which netperf)" ] 	|| packages=$packages" netperf"
#	[ -x  ] 			|| packages=$packages" "
if [ ! -z "$packages" ]
then #install packages
	if [ -x $(which aptitude) ]
	then #debian or ubuntu
		aptitude update && aptitude upgrade 
		aptitude install $packages
	elif [ -x $( which yum ) ]
	then #centos or fedora
		yum update
		echo "Please check for missing packages:"
		yum install $packages
		echo "Please check for missing packages!"
	else
		echo Failed to detect distribution, please make sure \
		necessary packages are installed. 
		exit 1
	fi
fi
}

# Userspace - bzip
test_zip() {
time bunzip2 -v -c $FILESDIR/$KERNEL       >$KERNELDIR/${KERNEL%.*} 2>/dev/null  2>$LOGDIR/bunzip2.log
time bzip2   -v -c $KERNELDIR/${KERNEL%.bz2} >$KERNELDIR/$KERNEL      2>/dev/null  2>$LOGDIR/bzip2.log
time tar -xv -f $KERNELDIR/${KERNEL%.bz2}    -C $KERNELDIR   	 2>/dev/null  2>$LOGDIR/untar.log
}

# Userspace kernel compile kernel compile 
test_kernelcompile() {
cd $KERNELDIR/${KERNEL%.tar.bz2}
make clean
cp $FILESDIR/$KERNELCONF ./.config
time make         | tee /dev/null >/dev/null 2>&1  >$LOGDIR/kernelmake.log
time make modules | tee /dev/null >/dev/null 2>&1 >>$LOGDIR/kernelmake.log
cd $BASEDIR
}

# lame
test_lame() {
for wave in $(cd $FILESDIR; ls *.wav)
do
	time lame $FILESDIR/$wave $LAMEDIR/${wave%.wav}.mp3 >$LOGDIR/${wave%.wav}-lame.log 2>/dev/null 2>$LOGDIR/${wave%.wav}-lametime.log
done
}

# unixbench
test_unixbench() {
cd $BASEDIR/unixbench
make clean
make | tee $LOGDIR/unixbench.log
#./Run index arithmetic system misc dhry | tee $LOGDIR/unixbench.log
make run | tee -a $LOGDIR/unixbench.log
make report | tee $LOGDIR/unixbench-report.log
cd $BASEDIR
}

# bonnie++
test_bonnie() {
bonnie -d TESTDIR -u $TESTUSER | tee $LOGDIR/bonnie.log
}

# iozone 
test_iozone() {
ozone -a | tee $LOGDIR/iozone.log
}

# dbench
test_dbench() {
dbench -D $TESTDIR $DBENCHNUMCLIENT | tee $LOGDIR/dbench.log
}

# iperf 
test_iperf_server() {
iperf
}
test_iperf() {
iperf
}

# tbench 
test_tbench_server() {
tbench -D $TESTDIR $DBENCHNUMCLIENT | tee $LOGDIR/dbench.log
}
test_tbench() {
tbench -D $TESTDIR $DBENCHNUMCLIENT | tee $LOGDIR/dbench.log
}

# Memory bandwidth test
test_mbandwidth() {
$mbandwidth 2>$LOGDIR/memory-bandwidth.log
}

# hardware info
test_hwinfo() {
lshw -short -C memory >$LOGDIR/memory-info.txt
dmidecode --type 17 >>$LOGDIR/memory-info.txt
}

# sysbench cpu
test_sysbench_cpu() {
sysbench --test=cpu  --cpu-max-prime=100000 run >$LOGDIR/sysbench-cpu.log
}



################################################################################
# MAIN

INIT=0
available_tests=$(grep test_.*\(\) $0 | sed -e 's/^.*test_//' | sort | cut -d\( -f1 | tr '\n' ' ' )
usage_information() {
printf "
Initializing and executing perofmance tests.

Usage: $(basename $0) [-h] [-i] [-t test1,test2...]
   -h	shows this help
   -i	initialize the environment
   -t	Available tests are: 
	$available_tests

This script must be run as root.
\n"  >&2
}

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
        usage_information >&2
	exit 1
fi

# parse command line
if [ $# -eq 0 ]; then #  must be at least one arg
        usage_information >&2
        exit 1
fi

while getopts 'dhijt:' OPTION
do
	case $OPTION in
	d)	set -x ;;
	i)	printf "\nInitializing environment....\n"
		init_env && exit 0 || exit 2
		;;
	j)	printf "\nInitializing server environment....\n"
		init_srv_env && exit 0 || exit 2
		;;
	t)	TESTS=$(echo "$OPTARG" | tr ',' ' ')
		invalid_tests=""
		all_tests_valid=0
		for requested_test in $TESTS
		do	requested_test_valid=0
			for valid_test in $available_tests
			do	if [ "$requested_test" = "$valid_test" ]
					then 	requested_test_valid=1
						any_valid_test=1
				fi
			done
			if [ $requested_test_valid = 0 ]
				then 	invalid_tests=$invalid_tests" "$requested_test
			fi
			if [ ! -z $invalid_tests ]
			then	echo You requested invalid tests: $invalid_tests.
				usage_information >&2
				exit 1
			fi
		done
		if [ ! $any_valid_test = 1 ]
		then	echo You need at least one valid test.
			exit 1
		fi
		;;
        h)	usage_information >&2
		exit 0
		;;
        \?)	usage_information >&2
		exit 1
		;;
	esac
done


for TEST in $TESTS
do	test_procedure="test_$TEST"
	echo Executing $test_procedure
	$test_procedure 
done

