#!/bin/sh
#set -x

# Exit codes
#  1	bad parameter syntax
#  2	failed to initialize


################################################################################
# parameters
################################################################################

KERNEL=linux-2.6.31.tar.bz2
KERNELCONF=config-2.6.31-14-server
TESTDIR=/var/lib/libvirt/images/bonnietest
TESTUSER=atlantis
DBENCHNUMCLIENT=10
IPERFSERVER=virtestserver.wall.test
IPERFNUMBYTES=1024M
IPERFNUMCLITHRD=2

################################################################################
# initialization
################################################################################

VERBOSE=0
INIT=0
JNIT=0
MYIP=$( ip -f inet route show dev eth0 | grep src | awk '{ print $7 }' )
BASEDIR=$(cd $(dirname $0); pwd)
FILESDIR=$BASEDIR/files
FILESWAVDIR=$FILESDIR/wav
WORKDIR=$BASEDIR/work
KERNELDIR=$WORKDIR/kernel
LAMEDIR=$WORKDIR/lame
LOGBASEDIR=$WORKDIR/logs/$(hostname)-${MYIP}

available_tests=$(grep test_.*\(\) $0 | sed -e 's/^.*test_//' | sort | cut -d\( -f1 | tr '\n' ' ' )

usage_information() {
	printf " 
`basename $0`     Initializing and executing perofmance tests.

Usage: $(basename $0) [-h] [-i] [-t test1,test2...]
   -h	shows this help
   -v	verbose
   -i	initialize the environment
   -T	timestamp or test identifier, defaults to `date +%Y%m%d`
   -t	Available tests are: 
	$available_tests

This script expects to be run as root.
\n"  >&2
}

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
        usage_information >&2
	exit 1
fi

# parse command line options
if [ $# -eq 0 ]; then #  must be at least one arg
        usage_information >&2
        exit 1
fi

while getopts 'dvijT:t:h' OPTION
do
	case $OPTION in
	d)	set -x ;;
	v)	VERBOSE=1;;
	i)	INIT=1
		;;
	j)	JNIT=1
		;;
	T)	TIMESTAMP=${OPTARG// /_}};;
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
			if [ ! -z "$invalid_tests" ]
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

[ -z $TIMESTAMP ] && TIMESTAMP=$(date +%Y%m%d)
LOGDIR=$LOGBASEDIR/$TIMESTAMP
cd $BASEDIR
mkdir -p $LOGDIR $KERNELDIR $LAMEDIR $TESTDIR
[ -L $LOGBASEDIR/latest ] && rm $LOGBASEDIR/latest || ln -s $TIMESTAMP $LOGBASEDIR/latest
chmod 777 $TESTDIR
uname -a | grep x86_64 >/dev/null && mbandwidth="./bandwith64" || mbandwidth="./bandwith32"

################################################################################
# functions
################################################################################

# set logging
set_logging() {
if [ $VERBOSE = 1 ]
then	 LOG=" | tee    $LOGDIR/${test_procedure}_output.log 2> $LOGDIR/${test_procedure}_error.log 2> $LOGDIR/${test_procedure}_time.log"
	LOGA=" | tee -a $LOGDIR/${test_procedure}_output.log 2>>$LOGDIR/${test_procedure}_error.log 2>>$LOGDIR/${test_procedure}_time.log"
	NOLOG=""
else	 LOG=" >        $LOGDIR/${test_procedure}_output.log 2> $LOGDIR/${test_procedure}_error.log 2> $LOGDIR/${test_procedure}_time.log"
	LOGA=" >>       $LOGDIR/${test_procedure}_output.log 2>>$LOGDIR/${test_procedure}_error.log 2>>$LOGDIR/${test_procedure}_time.log"
	NOLOG=">/dev/null 2>&1"
fi
}

init_env() {
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

################################################################################
#TESTS
################################################################################

test_zip() {
	eval time bunzip2 -v -c $FILESDIR/$KERNEL         >  $KERNELDIR/${KERNEL%.*} $LOG
	eval time bzip2   -v -c $KERNELDIR/${KERNEL%.bz2} >  $KERNELDIR/$KERNEL      $LOG
	eval time tar    -xv -f $KERNELDIR/${KERNEL%.bz2} -C $KERNELDIR              $LOG
}

test_compression() {
break #this doesn't work yet
plot="set terminal postscript, set output compression.ps, "
for compr in bzip2 lzma gzip
do	echo -n>$a
	for blocksize in $(seq 0 256)
	do 	dd if=/dev/zero of=$blocksize.zero bs=$blocksize count=1
		start=$(date +%s%N)
		$compr $b.zero
		end=$(date +%s%N)
		total=$(echo $end-$start|bc)
		echo $total>>$compr
		rm $blocksize.*
	done
	plot=${plot}", plot'"$compr" with lines, "
done
plot=$(echo $plot | sed s/\,\ $//)
echo $plot | gnuplot -persist $LOGDIR/${test_procedure}/compression.png
}

test_kernelcompile() {
	cd $KERNELDIR/${KERNEL%.tar.bz2}
	eval make clean $NOLOG
	eval cp -v $FILESDIR/$KERNELCONF ./.config $NOLOG
	eval time make         $LOG
	eval time make modules $LOGA
	cd $BASEDIR
}

test_lame() {
	for wave in $(cd $FILESWAVDIR; ls *.wav)
	do
		eval time lame $FILESDIR/$wave $LAMEDIR/${wave%.wav}.mp3 $LOG
	done
}

test_unixbench() {
	cd $BASEDIR/unixbench
	eval make clean $NOLOG
	eval make $LOG
	#./Run index arithmetic system misc dhry | tee $LOGDIR/unixbench.log
	eval make run    $LOGA
	eval make report $LOGA
	cd $BASEDIR
}

test_bonnie() {
	eval bonnie -d TESTDIR -u $TESTUSER $LOG
}

test_iozone() {
	eval ozone -a $LOG
}

test_dbench() {
	eval dbench -D $TESTDIR $DBENCHNUMCLIENT $LOG
}

test_iperf_server() {
	eval iperf -u -s > $LOGDIR/${test_procedure}_output.log 2> $LOGDIR/${test_procedure}_error.log & 
	echo $!
}

test_iperf() {
	eval iperf -u -c $IPERFSERVER -d -n $IPERFNUMBYTES -P $IPERFNUMCLITHRD  $LOG
}

test_tbench_server() {
	eval tbench_srv $LOG > $LOGDIR/${test_procedure}_output.log 2> $LOGDIR/${test_procedure}_error.log & 
	echo $!
}

test_tbench() {
	eval tbench -D $TESTDIR $DBENCHNUMCLIENT $TBENCHSERVER $LOG
}

test_mbandwidth() {
	eval $mbandwidth $LOG
}

test_hwmeminfo() {
	eval time lshw -short -C memory $LOG
	eval time dmidecode --type 17   $LOGA
}

test_sysbench_cpu() {
	eval time sysbench --test=cpu  --cpu-max-prime=100000 run $LOG
}


################################################################################
# MAIN
################################################################################

if [ $INIT = 1 ]
then	printf "\nInitializing server environment....\n"
	init_srv_env && exit 0 || exit 2

elif [ $JNIT = 1 ]
then	printf "\nInitializing environment....\n"
	init_env && exit 0 || exit 2

elif [ ! -z "$TESTS" ]
then	for TEST in $TESTS
	do	test_procedure="test_$TEST"
		echo Executing $test_procedure
		set_logging
		eval $test_procedure
	done
fi


