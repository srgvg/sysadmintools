#! /bin/sh
# run this script as root

# setup repo's
wget http://www.medibuntu.org/sources.list.d/intrepid.list -O /etc/apt/sources.list.d/medibuntu.list
echo "deb http://archive.canonical.com/ubuntu intrepid partner" > /etc/apt/sources.list.d/intrepid-partner.list
wget -q http://packages.medibuntu.org/medibuntu-key.gpg -O- | apt-key add - 

# enable universe and multiverse and partners but not backports
mv /etc/apt/sources.list /etc/apt/sources.list.bak
cat /etc/apt/sources.list.bak | sed "/\!ubuntu-backports/,/ universe/s/^# deb/deb/" | sed "/\!ubuntu-backports/,/ multiverse/s/^# deb/deb/" | sed "/ partner/s/^# deb/deb/" >/etc/apt/sources.list
apt-get update

# install packages
aptitude install \
	openssh-server apt-doc apt-dpkg-ref apt-rdepends apt-howto vim-full apt-file openssh-client traceroute tcptraceroute screen \
	ubuntu-restricted-extras nautilus-open-terminal nautilus-image-converter nautilus-gksu nautilus-actions nautilus-script-audio-convert nautilus-script-collection-svn nautilus-script-manager nautilus-share nautilus-wallpaper ntfsprogs filezilla filezilla-locales system-config-samba \
	ccsm compizconfig-settings-manager gnome-art usplash startupmanager padevchooser paman paprefs pavucontrol pavumeter \
	gstreamer0.10-plugins-bad gstreamer0.10-plugins-bad-multiverse gstreamer0.10-plugins-base gstreamer0.10-plugins-base-apps gstreamer0.10-plugins-good gstreamer0.10-plugins-ugly gstreamer0.10-plugins-ugly-multiverse gstreamer0.10-gnomevfs gstreamer0.10-alsa gstreamer0.10-tools gstreamer0.10-pitfdll gstreamer0.10-ffmpeg gstreamer-dbus-media-service gstreamer-tools gstreamer-tools gstreamer0.10-fluendo-mp3 gstreamer0.10-fluendo-mpegdemux gstreamer0.10-gnonlin gstreamer0.10-sdl totem-gstreamer gstreamer0.10-plugins-farsight gstreamer0.10-plugins-ugly gstreamer0.10-schroedinger gstreamer-dbus-media-service \
	sun-java6-bin sun-java6-fonts sun-java6-jre sun-java6-plugin \
	k3b quick-lounge-applet music-applet \
	acroread-escript acroread-plugins acroread mozilla-acroread libdvdcss2 w32codecs p7zip p7zip-full p7zip-rar \
	non-free-codecs

# liberation fonts
wget http://www.redhat.com/f/fonts/liberation-fonts.tar.gz
tar -xvf ./liberation-fonts.tar.gz  
mv liberation-fonts/ /usr/share/fonts/truetype/
fc-cache

# flash
# wget  http://fpdownload.macromedia.com/get/flashplayer/current/install_flash_player_9_linux.tar.gz
# tar -xvzf install_flash_player_9_linux.tar.gz
# sudo install_flash_player_9_linux/flashplayer-installer

#set default paper size
dpkg-reconfigure libpaper1

