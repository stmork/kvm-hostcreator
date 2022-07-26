#!/bin/bash
#
# SPDX-FileCopyrightText: © 2022 Steffen A. Mork
# SPDX-License-Identifier: MIT
#

. $HOME/bin/config-ubuntu.sh $@

if ! mountpoint -q "${MP}"; then
  echo "${VM_NAME} not mounted, nothing to do."
  exit 0
fi

LOOP=`findmnt -oSOURCE ${MP} | tail -n1 | grep -oP "loop\d*"`
NBD=/dev/${LOOP}

umount $MP/proc
umount $MP/sys
umount $MP/dev/pts
umount $MP/dev

umount $MP
kpartx -d ${NBD}
losetup -d ${NBD}
rmdir ${MP}
