#!/bin/bash

. $HOME/bin/config-ubuntu.sh $@

if [ ! -e $LIVE_ISO ]
then
	echo "The ISO $LIVE_ISO is not available!"
	exit 1
fi

virt-install -n $VM_NAME -f $DISK -r 1024 --vcpus=2\
	--os-type=linux --os-variant=ubuntuoneiric\
	--network bridge=$NETWORK\
	-c $LIVE_ISO\
	--graphics vnc,keymap=de --video=vga --noautoconsole\
	--accelerate --cpu host
