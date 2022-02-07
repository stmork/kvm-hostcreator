#!/bin/bash

# Start der Dienste deaktivieren
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

# localedef -i de_DE -c -f UTF-8 de_DE.UTF-8 
echo "Europe/Berlin" >/etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

apt-get update
apt-get dist-upgrade
apt-get install locales-all dialog console-setup

if [ -x bin/install-custom.sh ]
then
   echo "### Starting chrooted post installation script..."
   bin/install-custom.sh
fi

apt-get clean

# Setting locale and time zone.
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
locale-gen de_DE.UTF-8
localedef -i de_DE -c -f UTF-8 de_DE.UTF-8 
dpkg-reconfigure --frontend noninteractive locales

# Start der Dienste wieder reaktivieren
rm /sbin/initctl
dpkg-divert --local --rename --remove /sbin/initctl

killall -9 dirmngr
killall -9 gpg-agent

exit 0
