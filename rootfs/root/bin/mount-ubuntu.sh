#!/bin/bash

. $HOME/bin/config-ubuntu.sh $@

if mountpoint -q "${MP}"; then
  echo "${VM_NAME} already mounted."
  exit 0
fi

test -d $MP || mkdir -p $MP

echo "Clear mount..."
kpartx -d ${NBD}
losetup -d ${NBD}

set -e

echo "Remount..."
losetup ${NBD} ${DISK}
kpartx -a ${NBD}
sleep 1

echo "Mounting..."
mount $EXT4 $MP
mount -o bind /dev $MP/dev
mount -o bind /dev/pts $MP/dev/pts
mount -t sysfs /sys $MP/sys
mount -t proc /proc $MP/proc
cp /proc/mounts $MP/etc/mtab  
