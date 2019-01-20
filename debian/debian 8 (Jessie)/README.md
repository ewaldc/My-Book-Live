# My-Book-Live Debian Jessie 8.11

## What's included ? ##
The compressed tar [image](https://drive.google.com/open?id=1eCr4pyYLKAHId2QINgrGdd9GWCsWVGQG) contains:
- Debian 8.11
- Security post 8.11 patches backported to PowerPC
- MiniDLNA
- Rsync modified to use Kernel Crypto API
- Libkcapi + executables
- packages to compile and profile kernels
- kernel 4.9.99 pre-compiled
- SAMBA 4.x patched for performance
- NFS 4.x enabled
- 20+ Debian patches for powerpc
- u-boot tools

## How to install with ext2/ext3? ##

Make sure you have a solid backup (use dd to take an image backup)<br>
Read the debrick/unbrick guide posted [here](https://community.wd.com/t/guide-how-to-unbrick-a-totally-dead-mbl/56658/545) and download unbrick software (just in case)<br>
Open the MBL enclosure carefully, take the drive out and mount on a Linux system (search for a video on how to do this).<br>
Format the first partition on the drive e.g. /dev/sdb1 (or /dev/sdc1) in either ext2 or ext3

WARNING: THIS WILL ERASE ONE COPY OF THE ORIGINAL FW AND BREAK THE SOFTWARE RAID GROUP
`
mkfs.ext3 -m 1 /dev/sdb1 or (mkfs.ext2)`

The second partition still should have the official MBL distro as it’s a software raid 1 copy
mount the newly formatted partition
`
mkdir /mnt/mbl; mount /dev/sdb1 /mnt/mbl`

go to the root of the mountpoint:

`
cd /mnt/mbl`

Copy the Debian tar image to your Linux system in `/tmp` and extract the files :

`
tar xzf /tmp/DebianJessie8.11.tgz`

Sync and unmount the MBL drive:

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

- create /etc/rsyncd.secrets if needed

You will also need to configure users/groups (delete user ewald & tea), SAMBA partitions etc.
NFS export is enabled, but you will need to modify exportfs.
Your data partition should be untouched, it should be mounted on /DataVolume.
In case you start with a new drive, I have optimized the kernel driver for solid performance on a regular 4K file system which is readable on any Linux server and much easier to backup. I posted some performance numbers earlier.

It is still possible to go back to original FW by modifying `/boot/boot.scr` to boot off /dev/sda2

## How to install with ext4 ? ##
While MBL standard u-boot does not boot from ext4 (unless you upgrade u-boot), it is possible to have the root filesystem on ext4.  There are two ways to achive this:
- format /dev/sda1 to (a small sized) ext3, containing only /boot (kernel, boot.scr, apollo3g.dtb + eventually fall back copies of these files).  This provides extra room for a 2GB+ /dev/sda2 which then contains the root filesystem minus /boot, but including /lib/modules (loadable kernel modules)
- boot off TFTP with a initramfs enabled kernel which contains /boot.  This allows for a 4GB sized /dev/sda1 (/dev/sda2 can then be removed) or alternatively, to keep a copy of the original firmware on /dev/sda2 while hosting Debian Jessie 8.11 on /dev/sda1 (and the choice to boot either configuration)

Advanatges of using an ext4-only configuration include:
- smaller kernel (ext2/ext3 support can be removed)
- better overall performance
- better reliency