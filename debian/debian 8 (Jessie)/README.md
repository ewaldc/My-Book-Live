# My-Book-Live Debian Jessie 8.11

## What's included ? ##
The compressed tar [__image__](https://drive.google.com/open?id=1eCr4pyYLKAHId2QINgrGdd9GWCsWVGQG) contains:
- Debian 8.11
- Security post 8.11 patches backported to PowerPC
- MiniDLNA
- Rsync modified to use Kernel Crypto API
- Libkcapi + executables
- packages to compile and profile kernels
- kernel 4.9.99 pre-compiled
- SAMBA 4.x patched for performance
- NFS 4.x enabled
- 20+ Debian patches for powerpc not included in upstream Debian
- U-Boot firmware tools
- NetConsole (not enabled by default)

## Deciding where to host boot files and root filesystem ##
One of the challenges with the MBL is that the U-Boot version does not support booting from an ext4 file system.
Yet, for performance, interity and security (journalling, patches, security etc.) reasons, it is advised to have the root partition on an ext4 file system.   

Hece, to allow for proper boot, we must provide at least 3 files on one (or two) media that U-boot supports
- /boot/apollo3g.dtb (the kernel device tree in compile/binary format) (copied from /boot/apollo3g_duo.dtb for MBL duo)
- /boot/uImage (the kernel)
- /boot/boot.scr (the U-Boot command file that tells U-Boot where to find and how to start the kernel/OS)

The MBL version of U-Boot supports booting off:
- ext2 file system on disk
- ext3 file system on disk
- NFS file server
- TFTP/BOOTP server (e.g. an OpenWRT router with TFTPD enabled)
- and a few others such as Squashfs, Cramfs, Jffs2, Reiserfs, Ubifs, Yaffs2, ...

So the /boot folder of the Debian image with at least the 3 files mentioned must be on one of these file systems.

This leaves us with basically two alternatives:
- keep /boot and / together on a single filesystem.<br/>
  Typically that is an ext3 filesystem (ext2 is also possible) and now we have the choice between re-using /dev/sda1 or /dev/sda2 from the original firmware, or get rid of both sda1/sd2 and create a new volume that is double the size (4GB) and format that to ext3 filesystem.  It is still possible to have a software mirror between sda1 and sda2 like in the original FW, as long as it's formatted in ext2 or ext3.  The only file that needs to be customized is /boot/boot.scr, which tells U-Boot where to find the /boot files and what parameters it needs to pass on to the kernel
	
- separate /boot from / in order to leverage ext4 for root file system.<br/>
  One option is to use /dev/sda1 (in ext2/ext3 format) for /boot and /dev/sda2 for / (in ext4).  Here you have the choice to leave sda1 and sda2 at their original 2GB sizes, or you might create a smaller (e.g. 16MB) ext3 file system for sda1 and a larger (4GB -16MB) file system for sda2.  Just make sure sda2 is ext4, so you might need to re-format using mkfs.
	Alternatively, put /boot (3 files minimum) on a TFTP server (e.g. your router) and have / on either sda1, sda2 or a merged 4GB filesystem (in ext4 format).  Again, /boot/boot/scr must be customized to point to the proper locations.

Read more about advanced options for booting and U-Boot commands, including netconsole, auto-recovery kernels, mixed TFTP/disk booting and more in the __[U-Boot section](https://github.com/ewaldc/My-Book-Live/tree/master/uboot)__
  
## How to install a combined /boot and / with ext2/ext3? ##

Make sure you have a solid backup (use dd to take an image backup)<br>
Read the debrick/unbrick guide posted [here](https://community.wd.com/t/guide-how-to-unbrick-a-totally-dead-mbl/56658/545) and download unbrick software (just in case)<br>
Open the MBL enclosure carefully, take the drive out and mount on a Linux system (search for a video on how to do this).<br>
Format the first partition on the drive e.g. /dev/sdb1 (or /dev/sdc1) in either ext2 or ext3 (preferred)

WARNING: THIS WILL ERASE ONE COPY OF THE ORIGINAL FW AND BREAK THE SOFTWARE RAID GROUP<br>
`
mkfs.ext3 -m 1 /dev/sdb1 or (mkfs.ext2)`

The second partition still should have the official MBL distro as it’s a software raid 1 copy
mount the newly formatted partition.  So you can always go back to roginal OEM firmware if you like.
`
mkdir /mnt/mbl; mount /dev/sdb1 /mnt/mbl`

go to the root of the mountpoint:<br>
`
cd /mnt/mbl`

Copy the Debian tar image to your Linux system in `/tmp` and extract the files:<br>
`
tar xzf /tmp/DebianJessie8.11.tgz`

Sync and unmount the MBL drive:<br>
`
sync; umount /mnt/mbl`

Before rebooting:
- If you have a MBL Duo, ensure you have the proper device tree and copy /boot/apollo3g_duo.dtb to /boot/apollo3g.dtb
- Copy the right U-Boot boot command file for the github to /boot/boot.scr<br>
  When using /dev/sda1 use __[this file](https://github.com/ewaldc/My-Book-Live/blob/master/uboot/boot_ext3_sda1/boot.scr)__<br>
  When using /dev/sda2 use __[this file](https://github.com/ewaldc/My-Book-Live/blob/master/uboot/boot_ext3_sda2/boot.scr)__


Install the drive back into the MBL enclosure and boot<br>
Personalize the installation:
- change the root passwd (welc0me) using the `passwd` command
- rename your NAS server as follows (`myname` in the example)
```
export hostname="myname"
hostname $hostname
echo “127.0.0.1 $hostname localhost” > /etc/hosts
hostnamectl set-hostname “$hostname”
echo “$hostname” > /etc/hostname # uneeded

# clean up ssh
rm /etc/ssh/ssh_host* _
dpkg-reconfigure openssh-server
systemctl restart ssh

# re-load key services
invoke-rc.d hostname.sh start
invoke-rc.d networking force-reload
invoke-rc.d network-manager force-reload
```
- fix /etc/apt/source.list to list updated package repositories
Since Debian is no longer supported for 32-bit PowerPC, the package depots have moved to archive.
```
deb http://archive.debian.org/debian/ jessie main contrib non-free
``` 

- optionally, add Debian port repositories
If you are looking for the latest packages such as gcc verson 8.30, you can also include
```
# Debian ports
deb http://ftp.ports.debian.org/debian-ports unstable main
deb http://ftp.ports.debian.org/debian-ports unreleased main
```
But, be careful: do not do a full update from these respositories as you **may** end up with a non booting system

- create /etc/rsyncd.secrets if needed

You will also need to configure users/groups (delete user ewald & tea), SAMBA partitions etc.
NFS export is enabled, but you will need to modify exportfs.
Your data partition should be untouched, it should be mounted on /DataVolume.
In case you start with a new drive, I have optimized the kernel driver for solid performance on a regular 4K file system which is readable on any Linux server and much easier to backup. I posted some performance numbers earlier.

It is still possible to go back to original FW by modifying `/boot/boot.scr` to boot off /dev/sda2

## How to install with ext4 ? ##
While MBL standard u-boot does not boot from ext4 (unless you upgrade u-boot), it is possible to have the root filesystem on ext4.  There are two ways to achive this:
- format /dev/sda1 to (optionally a small sized) ext3, containing only /boot (kernel, boot.scr, apollo3g.dtb + eventually fallback copies of these files).  This mini boot filesystem provides extra room for a 3GB+ /dev/sda2 which then contains the ext4 root filesystem minus /boot, but including /lib/modules (loadable kernel modules)
- boot off TFTP with a initramfs enabled kernel which contains /boot.  This allows for a 4GB sized /dev/sda1 (/dev/sda2 can then be removed) or alternatively, to keep a copy of the original firmware on /dev/sda2 while hosting Debian Jessie 8.11 on /dev/sda1 (and the choice to boot either configuration)

Advantages of using an ext4-only configuration include:
- smaller kernel (ext2/ext3 support can be removed)
- better overall performance
- better resiliency

The installation follows a similar process as described above, except for:
- the need to have an ext3 file system for /boot and an ext4 filesystem for / (sda1/sda2 or reverse) unless you decide to boot off TFTP
- install the Debian tar image to the root file system (ext4)
- copy (or move) /boot to the ext3 file system

As above, before rebooting:
- If you have a MBL Duo, ensure you have the proper device tree and copy /boot/apollo3g_duo.dtb to /boot/apollo3g.dtb
- Copy the right U-Boot boot command file from the github to /boot/boot.scr<br>
  When using /dev/sda1 as /boot and /dev/sda2 as root, use __[this file](https://github.com/ewaldc/My-Book-Live/blob/master/uboot/boot_ext3_sda1/boot.scr)__<br>
  When using /dev/sda2 as /boot and /dev/sda1 as root, use __[this file](https://github.com/ewaldc/My-Book-Live/blob/master/uboot/boot_ext3_sda2/boot.scr)__

To use more advanced U-Boot options such as netconsole, auto-recovery kernels, mixed TFTP/disk booting and more, read the __[U-Boot section](https://github.com/ewaldc/My-Book-Live/tree/master/uboot)__
	
## Installing your own, clean Debian 8 (Jessie) ##

Martin Höfling has written a superb blog on this topic.  There is absolutely nothing I can add to improve on his very clear outline posted [here](https://www.schwabenlan.de/en/post/2015/04/clean-debian-install-on-mybook-live-nas/)

