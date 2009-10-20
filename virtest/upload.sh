#!/bin/sh
host=$1
shift
rsync -avL --delete $(dirname $0) root@$host:~/virtest/ --exclude=.swp $*

