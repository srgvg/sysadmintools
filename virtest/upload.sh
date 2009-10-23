#!/bin/sh
[ $# = 0 ] && { echo need target host; exit; }
host=$1
shift
rsync -avL --delete $(dirname $0) root@$host:~/virtest/ --exclude=.swp $*

