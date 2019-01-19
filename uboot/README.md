# My-Book-Live
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

The u-boot [file](https://github.com/ewaldc/My-Book-Live/blob/master/uboot/boot_recovery_netconsole.txt) supports two netconsole windows and two network cards. Feel free to simplify.

First redirect u-boot output and input to 'nc' (default port 6666 used):

`setenv nc 'setenv bootdelay 10; setenv stderr nc; setenv stdout nc; setenv stdin nc'`

Then set environment variables for IP and MAC addresses
```
setenv ipaddr '<_MBL IP address_>'
setenv ncIPLan '<i>PC LAN IP address</i>'
setenv ncMacLan '<_PC LAN MAC address_>'
setenv ncIPWLan '<_PC WLAN IP address_>'
setenv ncMacWLan '<_PC WLAN MAC address_>'
```

If _boot_count_ variable is not yet defined, initialize to zero:
`if itest -z "${boot_count}"; then setenv boot_count 0; fi`  

Increase _boot_count_ variable (MBL u-boot version does not allow expressions):
`if itest ${boot_count} == 0; then setenv boot_count 1; else setenv boot_count 2; fi`

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

Print all u-boot variables (mostly for debugging)
`printenv`

If _boot_count_ == 2 then load recovery kernel, else load default kernel:
```if itest ${boot_count} == 1; then echo "=== Loading Default Kernel ==="; run load_sata1; else echo "=== Loading Recovery Kernel ==="; run load_sata2; fi
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
See NetCatWindows.z

Start two nc windows: `netconsole.bat` and `uboot_neconsole.bat`