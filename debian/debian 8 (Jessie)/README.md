# My-Book-Live Debian Jessie 8.11

## What's included ##
The compressed tar [image](https://drive.google.com/open?id=1eCr4pyYLKAHId2QINgrGdd9GWCsWVGQG) contains:
- Debian 8.11
- Security patches backported to PowerPC
- MiniDLNA
- Rsync modified to use Kernel Crypto API
- Libkcapi + executables
- packages to compile andprofile kernels
- kernel 4.9.99 pre-compiled
- SAMBA patched for performance

To install :

# make sure you have a solid backup (use dd to take an image backup)
# read the debrick/unbrick guide post and download unbrick software (just in case)
# open the MBL enclosure carefully, take the drive out and mount on a Linux system (search for a video on how to do this)
# format the first partition on the drive e.g. /dev/sdc1 (or /dev/sdb1) in either ext2 or ext3

mkfs.ext3 -m 1 /dev/sdb1 or (mkfs.ext2)
# the second partition still should have the official MBL distro as it’s a software raid 1 copy
# mount the newly formatted partition
mount /dev/sdb1 /mnt/mbl
# go to the root of the mountpoint
cd /mnt/mbl
# install the Debian tar image
tar xzf /tmp/DebianJessie8.11.tgz
# sync and unmount
sync; umount /mnt/mbl

# install the drive back into the MBL enclosure and boot
# personalize the installation
# change the root passwd (welc0me)
passwd

# rename your server as follows (xyz in the example)
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

# Create /etc/rsyncd.secrets if needed

# You will also need to configure users/groups (delete user ewald & tea), SAMBA partitions etc.
# NFS export is enabled, but you will need to modify exportfs.
# Your data partition should be untouched, it should be mounted on /DataVolume.
# In case you start with a new drive, I have optimized the kernel driver for solid performance on a regular 4K file system which is readable on any Linux server and much easier to backup. I posted some performance numbers earlier.