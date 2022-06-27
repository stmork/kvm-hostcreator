# The KVM host creator
These bunch of scripts creates a KVM/qemu based virtual machine (in short
VM). You can create Ubuntu or Debian VMs and can customize the installation
process to get an actual unique VM.

The disk image uses one logical volume so LVM has to be already setup. Since
KVM/qemu/libvirt mostly connects the VMs to a bridge a bridging network
interface has also already to be installed correctly.

## The configuration
The configuration resides in the file _/etc/default/kvm-hostcreator_. the
file configures the following environment variables to customize the basic
installation of a VM.
1. _VG_NAME_: The volume group which should contain the logical volume.
2. _SIZE_: The default size of the logical volume in GiB.
3. _DISTR_: The default Debian/Ubuntu distribution to install.
4. _NETWORK_: The NIC to use to start the VM.
5. _LIVE_ISO_: The live iso image to use when starting the VM the first
time.

## The tools
1. Creating an Ubuntu VM with _create-ubuntu.sh_
2. Creating a Debian VM with _create-debian.sh_
3. Initial creation of a VM using _create-kvm.sh_
3. Mounting a VM with _mount-ubuntu.sh_
4. Unmounting a VM with _umount-ubuntu.sh_

# The installation process
The installation process proceeds through different stages which are
described here in detail. The usage of the tools _create-debian.sh_ and _create-ubuntu.sh_
are the same only some debootstrap and Linux kernel issues are different. So
call of both tools is the same.

The first parameter is the _VM_NAME_, the hostname of the virtual machine.
The second optional parameter is the _DISTR_, the distribution to use. Note
that this variable superseeds the variable from the file
_/etc/default/kvm-hostcreator_.

## Creating the logical volume
First the logical volume is created inside the volume group using the _VG_NAME_
variable. The default size is _SIZE_ GiB. Both variables are configured in
the file _/etc/default/kvm-hostcreator_. If the logical volume already
exists nothing will happen. So you can manually create a bigger one before
starting the creation process if needed. The naming scheme for the logical
volume name is _<VM_NAME>-disk01_ to allow adding of more disk images to the
VM later.

## Partitioning and formatting the logical volume
The logical volume is used as a disk image. So this disk image must be
partitioned using the GPT partitioning scheme. Before formatting the first
one GiB is zeroed out to destroy existing partitions. This stage creates
three partitions:
1. GRUB (4 MiB)
2. Swap (1020 MiB)
3. The filesystem (rest)

On GPT based partition tables GRUB needs its own partition for booting. 

After partitioning the Swap partition is initialized and the root filesystem
is formatted using the ext4 filesystem type. Auto checking is disabled both
based on time and mount count.

## Starting debootstrap
Now its time to mount the root filesystem and install a minimal
Debian/Ubuntu Linux based on _debootstrap_. This is the point where the
scripts _create-debian.sh_ and _create-ubuntu.sh_ differs since the
installation is minimal different for both distributions, e.g. the download
URL.

## Copying raw filesystem structure
After installing the base system the contents of the directory
_/root/deboot/_ is copied recursively using _rsync_. This directory also
contains the post installation scripts which are called later using
_chroot_. Feel free to add contents into that directory to customize to your
needs such additional configuration files. It is a good place to add for
example a proxy server configuration to the _apt_ subsystem.

There is a post copy feature which replaces all _%DISTR%_ token occurences
in the files with the real _DISTR_ environment variable given by parameter
or by default from the file _/etc/default/kvm-hostcreator_. So it is
possible to add additional _sources.list_ files which may contain the
distribution.

Finally the file _/etc/resolv.conf_ is copied into the VM to ensure same
hostname resolution as of the host.

## Postunpacking
In this stage the file _/etc/hostcreator/postunpack.sh_ is called if
existing. You can adjust this file as you need. It is a good place to add
additional APT key downloads using the _gpg2_ tool. The precedure may differ
depending on what software sites you use. The create scripts call this hook
with the virtual hostname as the first parameter, the temporal mount point
as the second parameter and the _DISTR_ variable as the third parameter.

This is also the stage where the virtual hostname is configured and some
useful aliases are added to the root users bash profile file.

## Postinstallation
There are some jobs needed in a chrooted environment on the newly created
virtual machine. Now the create scripts start the
_/root/deboot/root/bin/install.sh_ script which is already copied earlier
through the raw copy stage and appears in the VM as file
_/root/bin/install.sh_.

The intention of that script is to configure date time and language
settings. Additionally the automiatic service start is disabled because this
would take place in the hosts runtime environment which is not intended.
After that stage the APT subsystem has already updated the package revision
database and upgraded pending updates.

If the script _/root/bin/install-custom.sh_ exists in the filesystem it is
called to add installation of packages you need additionally. So adjust the
file _/root/deboot/root/bin/install-custom.sh_ prior VM creation on your
demands. Since the surrounding _install.sh_ script disables automatic
service start it is a good place to install additional packages on your
needs.

It is also a possible to set the root password. But I recommend setting the
needed ssh public keys via the raw copy stage for security reasons instead.

Finally the automatic service start is reactivated to allow them when
booting the VM itself.

## Postconfiguration
After that there is another hook in file _/etc/hostcreator/postconfig.sh_ on
host side which is called now if existing. The create scripts call this hook
with the virtual hostname as the first parameter, the temporal mount point
as the second parameter and the _DISTR_ variable as the third parameter.

At this point you can do some cleanup work but mostly everything is already
done.

## Installing GRUB
The final stage installs the Linux kernel and configures GRUB. The script
_/root/bin/grub-debian.sh_ or _/root/bin/grub-ubuntu.sh_ respectively is
called chrooted inside the VM for this purpose.

After installing grub all mount points necessary for installation are
unmounted and completed hopefully successful.

## Starting the VM for the first time
After installation you can configure the VM on your own using the
_virt-manager_ tool or you can call the _create-kvm.sh_ script once to
create a KVM/qemu instance and start it. When you call the script you have
to add the virtual hostname to the script.

Note that an existing KVM/qemu instance is _not_ overwritten!
