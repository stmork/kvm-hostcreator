#!/bin/bash

NBD=${1:-/dev/loop0}

export DEBIAN_FRONTEND=noninteractive
apt-get install linux-image-amd64 grub-pc systemd-sysv

echo "### Installing GRUB on device ${NBD}..."

grub-mkconfig -o /boot/grub/grub.cfg
grub-install ${NBD}

killall -9 dirmngr
killall -9 gpg-agent

exit 0
