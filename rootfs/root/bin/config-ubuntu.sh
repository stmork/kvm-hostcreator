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

LOOP=`losetup -f | cut -d/ -f3`
SWAP=/dev/mapper/${LOOP}p2
EXT4=/dev/mapper/${LOOP}p3
NBD=/dev/${LOOP}
