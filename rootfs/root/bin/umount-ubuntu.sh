#!/bin/bash

. $HOME/bin/config-ubuntu.sh $@

if [ -z ${MOUNTED} ]; then
  echo "${VM_NAME} not mounted, nothing to do."
  exit 0
fi

umount $MP/proc
umount $MP/sys
umount $MP/dev/pts
umount $MP/dev

umount $MP
kpartx -d ${NBD}
losetup -d ${NBD}
rmdir ${MP}
