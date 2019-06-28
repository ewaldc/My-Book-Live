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
- u-boot tools
- NetConsole enabled by default

## Deciding where to host /boot and / (the root filesystem) ##
One of the challenges with the MBL is that the U-Boot version does not support booting from an ext4 file system.
But, in modern times we would like to have the root partition / on ext4 because of performance, interity and security (journalling, patches, security etc.).   

To boot properly, we must provide at least 3 files on one (or two) media that U-boot recognizes
- /boot/apollo3g.dtb (the kernel device tree in compile/binary format) or /boot/apollo3g_duo.dtb (for MBL duo)
- /boot/uImage (the kernel)
- /boot/boot.scr (the U-Boot command file that tells U-Boot where to find the kernel and OS)

The MBL version of U-Boot supports booting off:
- ext2 file system on disk
- ext3 file system on disk
- NFS file server
- TFTP/BOOTP server (e.g. an OpenWRT router with TFTPD enabled)
- and a few others such as Squashfs, Cramfs, Jffs2, Reiserfs, Ubifs, Yaffs2, ...

Hence the /boot folder of the Debian image with at least the 3 files mentioned must be on one of these file systems.
This leaves us with two alternatives:
- keep /boot and / together on a single filesystem
  Typically that is an ext3 (or ext2) filesystem and we have the choice between re-using /dev/sda1 or /dev/sda2 from the original firmware, or simple merge them in a 4GB filesystem.  Also possible is to have a software mirror between sda1 and sda2 like in the original FW, as long as it's ext2 or ext3.  The only file that needs to be customized is /boot/boot.scr, which needs to tell U-Boot where to find the /boot files and what parameters it needs to pass on to the kernel
- separate /boot from /
  Typically that would be /dev/sda1 (in ext2/ext3 format) for /boot and /dev/sda2 for / (in ext4).
  Alternatively, locate /boot (3 files minimum) on a TFTP server (e.g. your router) and have / on either sda1, sda2 or a merged 4GB filesystem (in ext4 format).  Again, /boot/boot/scr must be customized to point to the proper locations.
  
## How to install a combined /boot and / with ext2/ext3? ##

Make sure you have a solid backup (use dd to take an image backup)<br>
Read the debrick/unbrick guide posted [here](https://community.wd.com/t/guide-how-to-unbrick-a-totally-dead-mbl/56658/545) and download unbrick software (just in case)<br>
Open the MBL enclosure carefully, take the drive out and mount on a Linux system (search for a video on how to do this).<br>
Format the first partition on the drive e.g. /dev/sdb1 (or /dev/sdc1) in either ext2 or ext3

WARNING: THIS WILL ERASE ONE COPY OF THE ORIGINAL FW AND BREAK THE SOFTWARE RAID GROUP<br>
`
mkfs.ext3 -m 1 /dev/sdb1 or (mkfs.ext2)`

The second partition still should have the official MBL distro as it’s a software raid 1 copy
mount the newly formatted partition
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
- format /dev/sda1 to (a small sized) ext3, containing only /boot (kernel, boot.scr, apollo3g.dtb + eventually fallback copies of these files).  This mini boot filesystem provides extra room for a 2GB+ /dev/sda2 which then contains the root filesystem minus /boot, but including /lib/modules (loadable kernel modules)
- boot off TFTP with a initramfs enabled kernel which contains /boot.  This allows for a 4GB sized /dev/sda1 (/dev/sda2 can then be removed) or alternatively, to keep a copy of the original firmware on /dev/sda2 while hosting Debian Jessie 8.11 on /dev/sda1 (and the choice to boot either configuration)

Advantages of using an ext4-only configuration include:
- smaller kernel (ext2/ext3 support can be removed)
- better overall performance
- better resiliency

## Installing your own, clean Debian 8 (Jessie) ##

Martin Höfling was written a superb blog on this topic.  There is absolutely nothing I can add to improve on his very clear outline posted [here](https://www.schwabenlan.de/en/post/2015/04/clean-debian-install-on-mybook-live-nas/)

## Final step before booting ##
The one file that needs modification is /boot/boot.scr
You can find examples and a tool to compile this file in the uboot section.
To simplify things I will post a couple of precompiled boot.scr files that correspond to the most popular scenarios
