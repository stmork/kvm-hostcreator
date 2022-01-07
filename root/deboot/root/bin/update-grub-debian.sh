#!/bin/bash

touch /etc/mtab

mount -t devtmpfs /dev /dev
mount -t devpts /dev/pts /dev/pts
mount -t sysfs /sys /sys
mount -t proc proc /proc

apt-get install linux-image-amd64 grub-pc

umount /dev/pts
umount /dev
umount /proc
umount /sys

rm -f /usr/sbin/policy-rc.d
