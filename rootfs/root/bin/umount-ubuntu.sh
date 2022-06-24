#!/bin/bash

. $HOME/bin/config-ubuntu.sh $@

if ! mountpoint -q "${MP}"; then
  echo "${VM_NAME} not mounted, nothing to do."
  exit 0
fi

NBD=/dev/`df -h | grep ${MP} | grep -oP "loop\d*"`

umount $MP/proc
umount $MP/sys
umount $MP/dev/pts
umount $MP/dev

umount $MP
kpartx -d ${NBD}
losetup -d ${NBD}
rmdir ${MP}
