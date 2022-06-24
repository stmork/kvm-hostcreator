#!/bin/bash

NBD={$1:-/dev/loop0}

export DEBIAN_FRONTEND=noninteractive
apt-get install linux-image-generic
apt-get install grub-pc

grub-mkconfig -o /boot/grub/grub.cfg
grub-install ${NBD}

killall -9 dirmngr
killall -9 gpg-agent

exit 0
