#!/bin/bash


if [ "$(whoami)" != 'root' ]; then
  echo "You need to be root or use sudo to create packages the right way"
  exit 1;
fi


# Check possible distributions and assign trailing minor version to them
RELEASE=""
if [ $# == 1 ]; then
	case "$1" in
		intrepid)
			RELEASE="-0intrepid"
			;;
		lenny)
			RELEASE="-0lenny"
			;;
		jaunty)
			RELEASE="-0jaunty"
			;;
		*)
			echo "no valid release given.  No release = default = hardy.  Other possible values: intrepid, jaunty, lenny"
			exit 1
			;;
	esac
fi


# A vpan group on the system is necessary for correct permissions
if ! grep vpan /etc/group > /dev/null
	then
		addgroup vpan
		echo "added group vpan"
fi


# Assign correct variables
TEMPDIR="/tmp/$(date +%s)"
if [ "$(dirname $0)" == "." ]; then
	PACKAGEDIR="$(pwd)";
else
	PACKAGEDIR="$(dirname $0)"
fi
PACKAGE="$(basename $PACKAGEDIR)"
SCRIPTNAME="$(basename $0)"


# Copy package to tempdir, fix permissions and remove package building scripts
mkdir -p $TEMPDIR
cp -r $PACKAGEDIR $TEMPDIR/
for i in `find $TEMPDIR/$PACKAGE | grep ".svn"`; do
	rm -rf $i;
done
if [ -a $TEMPDIR/$PACKAGE/fixperms.sh ]; then
	$TEMPDIR/$PACKAGE/fixperms.sh $TEMPDIR/$PACKAGE
	rm $TEMPDIR/$PACKAGE/fixperms.sh;
fi
rm $TEMPDIR/$PACKAGE/$SCRIPTNAME


# Insert correct installed size
INSTALLED_SIZE=`du -s --exclude=DEBIAN $TEMPDIR/$PACKAGE | awk '{print $1}'`
sed -i "s/^Installed.*\$/Installed-size: $INSTALLED_SIZE/" $TEMPDIR/$PACKAGE/DEBIAN/control


# Correct the version number with minor distro version (empty in case of default)
sed -i "s/^Version\(.*\)[ \t]*$/Version\1$RELEASE/" $TEMPDIR/$PACKAGE/DEBIAN/control


# For the VPAN package, the dependency of libpcap0.8 is necessary for intrepid and lenny
if [ "$1" == 'intrepid' ]; then
	echo "VPAN for intrepid!"
	sed -i "s/^Pre-Depends\(.*\)libpcap0.7\(.*\)$/Pre-Depends\1libpcap0.8\2/" $TEMPDIR/$PACKAGE/DEBIAN/control
fi
if [ "$1" == 'jaunty' ]; then
	echo "VPAN for jaunty!"
	sed -i "s/^Pre-Depends\(.*\)libpcap0.7\(.*\)$/Pre-Depends\1libpcap0.8\2/" $TEMPDIR/$PACKAGE/DEBIAN/control
fi
if [ "$1" == 'lenny' ]; then
	echo "VPAN for lenny!"
	sed -i "s/^Pre-Depends\(.*\)libpcap0.7\(.*\)$/Pre-Depends\1libpcap0.8\2/" $TEMPDIR/$PACKAGE/DEBIAN/control
fi


# Build the package, yihaw!
dpkg-deb -b $TEMPDIR/$PACKAGE

# Assign a correct name, copy it back to the packages dir and delete the temp dir
VERSION=`grep Version $TEMPDIR/$PACKAGE/DEBIAN/control | awk '{print $2 }'`
DEBNAME="$PACKAGE"_"$VERSION"_i386.deb
cp $TEMPDIR/"$PACKAGE".deb $(dirname $PACKAGEDIR)/$DEBNAME
rm -rf $TEMPDIR

echo "Built $DEBNAME"

exit 0
