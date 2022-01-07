#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get install linux-image-generic
apt-get install grub-pc

grub-mkconfig -o /boot/grub/grub.cfg
grub-install /dev/loop0

killall -9 dirmngr
killall -9 gpg-agent

exit 0
