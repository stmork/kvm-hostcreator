#!/bin/bash

#set -e

if [ $# -lt 1 ]
then
	echo "Usage:"
	echo "$0 VM-HOSTNAME [DISTRIBUTION]"
	exit 1
fi

. $HOME/bin/config-ubuntu.sh $@

if [ ! -z ${MOUNTED} ]; then
        echo "${VM_NAME} is mounted! Run umount-ubuntu.sh first."
        exit 1
fi

if [ $# -ge 2 ]
then
	DISTR=$2
fi

kpartx -d /dev/${NBD}
losetup -d ${NBD}

echo "### Preparing LV for $VM_NAME..."
if [ -e ${DISK} ]
then
	LE_COUNT=`lvdisplay ${DISK}|fgrep LE|sed -e 's/[^0-9]//g'`
else
	let LE_COUNT=${SIZE}\*1024/${LE_SIZE}
	lvcreate -l $LE_COUNT -n $LV_NAME $VG_NAME
fi

echo "### Partitioning $VM_NAME..."
dd if=/dev/zero of=${DISK} bs=${LE_SIZE}M count=2
dd if=/dev/zero of=${DISK} bs=${LE_SIZE}M seek=`expr $LE_COUNT - 2` count=2

let BORDER=${LE_SIZE}\*2048
let START_GRUB=${BORDER}
let START_SWAP=${BORDER}\*2
let START_EXT4=${BORDER}\*512

sgdisk -z ${DISK}
sgdisk -a${BORDER} -n1:${START_GRUB}:`expr ${START_SWAP} - 1` -n2:${START_SWAP}:`expr $START_EXT4 - 1`  -n3:${START_EXT4} -t1:ef02 -t2:8200 ${DISK}
gdisk -l ${DISK}

set -e

losetup ${NBD} ${DISK}
kpartx -a ${NBD}
sleep 1

echo "### Formatting $VM_NAME..."
mkswap ${SWAP}
mkfs.ext4 -F -L $VM_NAME $EXT4
tune2fs -c0 -i0 $EXT4

echo "### Mounting $VM_NAME..."
test -d $MP || mkdir $MP
mount $EXT4 $MP

echo "### Installing $VM_NAME..."
debootstrap --variant=minbase --include=gnupg2,tcsh,psmisc --arch=amd64 $DISTR $MP http://ftp.de.debian.org/debian

echo "### Configuring distro $DISTR..."
rsync -a $HOME/deboot/ $MP/
for FILE in `find $HOME/deboot/ -type f -printf "%P\\n"`
do
	sed -i -e "s/%DISTR%/$DISTR/g" $MP/$FILE
done
rm -f $MP/etc/apt/sources.list.d/ubuntu.list

cp /etc/resolv.conf  $MP/etc/

mount -o bind /dev $MP/dev
mount -o bind /dev/pts $MP/dev/pts
mount -t sysfs /sys $MP/sys
mount -t proc /proc $MP/proc
cp /proc/mounts $MP/etc/mtab  

if [ -x /etc/hostcreator/postunpack.sh ]
then
	echo "### Starting post unpack script..."
	/etc/hostcreator/postunpack.sh $VM_NAME $MP $DISTR
fi

echo $VM_NAME >$MP/etc/hostname
echo "" >>$MP/root/.profile
echo "alias ll='ls -l'" >>$MP/root/.profile
echo "alias tm='tail -f -n 100 /var/log/syslog'" >>$MP/root/.profile

echo "### Starting chroot installation..."
chroot $MP /bin/bash -c "su - -c bin/install.sh"

if [ -x /etc/hostcreator/postconfig.sh ]
then
	echo "### Starting post configuration script..."
	/etc/hostcreator/postconfig.sh $VM_NAME $MP $DISTR
fi

echo "### Installing GRUB..."
chroot $MP /bin/bash -c "su - -c bin/grub-debian.sh"

# Going out...
echo "### Unmounting..."
umount $MP/proc
umount $MP/sys
umount $MP/dev/pts
umount $MP/dev
rm $MP/etc/mtab
umount $MP
kpartx -d ${NBD}
losetup -d ${NBD}
