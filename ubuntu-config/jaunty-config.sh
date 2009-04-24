#! /bin/sh
# run this script as root

# add medibuntu repo
wget http://www.medibuntu.org/sources.list.d/jaunty.list -O /etc/apt/sources.list.d/medibuntu.list
wget -q http://packages.medibuntu.org/medibuntu-key.gpg -O- | apt-key add - 

aptitude update

# install packages
aptitude install \
	openssh-server apt-rdepends vim-full apt-file openssh-client traceroute tcptraceroute screen \
	ubuntu-restricted-extras nautilus-open-terminal nautilus-image-converter nautilus-gksu nautilus-actions nautilus-script-audio-convert nautilus-script-collection-svn nautilus-script-manager nautilus-share nautilus-wallpaper ntfsprogs filezilla filezilla-locales system-config-samba \
	ccsm compizconfig-settings-manager gnome-art usplash startupmanager padevchooser paman paprefs pavucontrol pavumeter wallpaper-tray terminator \
	gstreamer0.10-plugins-bad gstreamer0.10-plugins-bad-multiverse gstreamer0.10-plugins-base gstreamer0.10-plugins-base-apps gstreamer0.10-plugins-good gstreamer0.10-plugins-ugly gstreamer0.10-plugins-ugly-multiverse gstreamer0.10-gnomevfs gstreamer0.10-alsa gstreamer0.10-tools gstreamer0.10-pitfdll gstreamer0.10-ffmpeg gstreamer-dbus-media-service gstreamer-tools gstreamer-tools gstreamer0.10-fluendo-mp3 gstreamer0.10-fluendo-mpegdemux gstreamer0.10-gnonlin gstreamer0.10-sdl totem-gstreamer gstreamer0.10-plugins-farsight gstreamer0.10-plugins-ugly gstreamer0.10-schroedinger gstreamer-dbus-media-service \
	sun-java6-bin sun-java6-fonts sun-java6-jre sun-java6-plugin \
	quick-lounge-applet music-applet mozplugger ttf-liberation \
	acroread-plugins acroread libdvdcss2 w64codecs w32codecs p7zip p7zip-full p7zip-rar \
	non-free-codecs

#set default paper size
dpkg-reconfigure libpaper1

