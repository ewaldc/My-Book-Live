# My-Book-Live netconsole

## Introduction to netconsole ##
First read about netconsole here: https://www.kernel.org/doc/Documentation/networking/netconsole.txt

The WD MBL netconsole implementation requires the following:
- netconsole enabled uboot files
- netconsole enabled kernel
- netconsole enabled Linux kernel patches and config file (if you want to compile your own kernel)

DO NOT TEST THIS WITHOUT ABILITY TO TAKE YOUR DRIVE OUT AND HOOK TO A LINUX SYSTEM

## Building a kernel with ntconsole support ##
On WD MBL platforms this requires both a pacth as well as enabling netconfig in the kernel.
Alternatively, download a precompiled, netconsole-enabled kernel


##
## Building u-boot boot file using netconsole ##

u-boot is looking for a boot file called `/boot/boot.scr`

generate with
```
./mkBootSrc.sh boot_recovery_netconsole
cp boot_recovery_netconsole.scr boot.scr
cp /boot/
/dev/mtd0 0x1f000 0x1000 0x1000 1 
EOF
```

## Building u-boot boot file with double netconsole support ##
Please note that the sample file assumes booting off an ext4 root partition on `/dev/sda2`.
It's perfectly possible to boot off `/dev/sda1` using ext2/3 and keep a copy of the original firmware on `/dev/sda2`. See Debian Jessie [readme](https://github.com/ewaldc/My-Book-Live/blob/master/debian/debian%208%20(Jessie)/README.md) for more information.

Test if you have the mkimage command, if not install it using `apt install u-boot-tools`:
```
mkimage -?
apt install u-boot-tools
```

Then create your boot file using the u-boot template file [boot_recovery_netconsole.txt](https://github.com/ewaldc/My-Book-Live/blob/master/uboot/boot_recovery_netconsole.txt) supports two netconsole windows and two network cards. Feel free to simplify.

First redirect u-boot output and input to 'nc' (default port 6666 used):

`setenv nc 'setenv bootdelay 10; setenv stderr nc; setenv stdout nc; setenv stdin nc'`

Then set environment variables for IP and MAC addresses (substitute text between <>)
```
setenv ipaddr '<_MBL IP address_>'
setenv ncIPLan '<PC LAN IP address>'
setenv ncMacLan '<PC LAN MAC address>'
setenv ncIPWLan '<PC WLAN IP address>'
setenv ncMacWLan '<PC WLAN MAC address>'
```

If _boot_count_ variable is not yet defined, initialize to zero:

`
if itest -z "${boot_count}"; then setenv boot_count 0; fi`  

Increase _boot_count_ variable (MBL u-boot version does not allow expressions):

`
if itest ${boot_count} == 0; then setenv boot_count 1; else setenv boot_count 2; fi`

Save environment and enable netconsole redirection (evaluate nc variable)
```
saveenv
run nc
```

Define linux kernel boot arguments, including kernel netconsole ports:

```
setenv bootargs_lan 'setenv bootargs netconsole=6663@${ipaddr}/,6664@${ncIPLan}/${ncMacLan} root=/dev/sda2 earlyprintk rw rootfstype=ext4 rootflags=data=ordered'
setenv bootargs_wlan 'setenv bootargs netconsole=6663@${ipaddr}/,6664@${ncIPWLan}/${ncMacLan} root=/dev/sda2 earlyprintk rw rootfstype=ext4 rootflags=data=ordered'
setenv load_sata1 'sata init; ext2load sata 1:1 ${kernel_addr_r} /boot/uImage; ext2load sata 1:1 ${fdt_addr_r} /boot/apollo3g.dtb'
setenv load_sata2 'sata init; ext2load sata 1:1 ${kernel_addr_r} /boot/uImage.safe; ext2load sata 1:1 ${fdt_addr_r} /boot/apollo3g.safe.dtb'
setenv boot_sata 'run bootargs_lan addtty; bootm ${kernel_addr_r} - ${fdt_addr_r}'
```

Print all u-boot variables (mostly for debugging):

`printenv`

If _boot_count_ == 2 then load recovery kernel, else load default kernel:
```
if itest ${boot_count} == 1; then echo "=== Loading Default Kernel ==="; run load_sata1; else echo "=== Loading Recovery Kernel ==="; run load_sata2; fi
run boot_sata
```

## Reading and writing u-boot environment flash from Debian Jessie ##
How to avoid opening the My Book Live shell in case a boot failure:
* (low-level) format the embedded hard drive
* u-boot fails to boot from harddisk 

One of the requirements to make this all work is the ability to read/write the u-boot environment stored in nor flash from the OS, which is stored within /dev/mtd0.

First install u-boot-tools:
`apt-get install u-boot-tools`

Then create /etc/fw_env.config:

```
cat >/etc/fw_env.config <<EOF
/dev/mtd0 0x1e000 0x1000 0x1000 1
/dev/mtd0 0x1f000 0x1000 0x1000 1 
EOF
```

Now you can check your environment: 
`fw_printenv`
And set a variable: 
`fw_setenv variable value`

In this way a running operation system can feedback to u-boot that booting has successfully completed and there is no need to try a fallback boot image.  Additionally, it could fallback on TFTP/BOOTP boot.


## Netcat for windows ##
See [NetCatWindows.z](https://github.com/ewaldc/My-Book-Live/blob/master/uboot/NetCatWindows.7z)

Start two nc windows: `netconsole.bat` and `uboot_neconsole.bat`