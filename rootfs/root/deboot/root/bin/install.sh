#!/bin/bash

# Start der Dienste deaktivieren
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

localedef -i de_DE -c -f UTF-8 de_DE.UTF-8 
echo "Europe/Berlin" >/etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

#gpg --list-keys
#gpg --keyserver hkp://keys.gnupg.net --recv-keys 5DF9FE64265CF59A B1C9D94396E2F2AD
#gpg --export 5DF9FE64265CF59A | apt-key add -
#gpg --export B1C9D94396E2F2AD | apt-key add -

apt-get update
apt-get dist-upgrade
apt-get install locales-all dialog console-setup

test -x bin/install-custom.sh && bin/install-custom.sh

sed -i -e "s/ -nobackups/-nobackups/g"  /etc/joe/joerc

echo "SNMPDOPTS='-Ln -u snmp -I -smux -p /var/run/snmpd.pid 127.0.0.1'" >>/etc/default/snmpd
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
