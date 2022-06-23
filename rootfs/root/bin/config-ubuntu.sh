#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Usage:"
	echo "$0 hostname"
	exit 1
fi

. /etc/default/kvm-hostcreator

VM_NAME=$1
LE_SIZE=4
LV_NAME=${VM_NAME}-disk01
DISK=/dev/${VG_NAME}/${LV_NAME}
MP=/tmp/mp-${VM_NAME}
MOUNTED=`df -h | grep ${MP} | grep -oP "loop\d*"`

if [ -z ${MOUNTED} ]; then
	# The mount point has actually no loop device mounted, 
	# take the next free loop device.
	LOOP=`losetup -f | cut -d/ -f3`
	SWAP=/dev/mapper/${LOOP}p2
	EXT4=/dev/mapper/${LOOP}p3
else
	# The mount point has a loop device mounted.
	LOOP=${MOUNTED}
fi

NBD=/dev/${LOOP}
