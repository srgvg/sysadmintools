#!/bin/bash

aptdir="/opt/www/apt"
distdirs=$(ls ${aptdir})

cd ${aptdir}
for dist in ${distdirs}
do
	if [ ! -L ${aptdir}/${dist} ]
	then
		echo scanning ${aptdir}/${dist} and generating ${aptdir}/${dist}/NEW-Packages.gz
		echo
		dpkg-scanpackages -m ${dist} /dev/null | gzip -9c > ${aptdir}/${dist}/NEW-Packages.gz
		echo
		echo -n "    "; mv -v ${aptdir}/${dist}/NEW-Packages.gz ${aptdir}/${dist}/Packages.gz
		echo
	fi
done
