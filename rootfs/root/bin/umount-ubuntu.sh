#!/bin/bash

. $HOME/bin/config-ubuntu.sh $@

umount $MP/proc
umount $MP/sys
umount $MP/dev/pts
umount $MP/dev

umount $MP
kpartx -d ${NBD}
losetup -d ${NBD}
rmdir ${MP}
