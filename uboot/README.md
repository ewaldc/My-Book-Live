# My-Book-Live netconsole and safe/recovery kernels

When developing and/or installing kernels for MBL, it's good to be able to count on 4 functionalities:
- ability to fall back on a working kernel and binary/compiled device tree file (apollo3g*.dtb) when a development kernel fails to boot or is so slow that there is no chance to restore a working kernel
- ability to interact with uboot console
- ability to watch kernel boot log (dmesg) in real time
- ability to boot from a network device (TFTP) in case booting of your drive is not longer working (and you don't want to open up your MBL)

This section explains how you can achieve these 4 capabilities.

## Introduction to u-boot environment variables and boot file (/boot/boot.scr) ##
Read __[here](https://www.denx.de/wiki/U-Boot)__ to understand what u-boot does and how it works in details.
Basically, our MBL hardware has a 2012 version of u-boot flashed onto NAND flash. When you power on the MBL, the board boots into the u-boot boot loader. From there, u-boot has a number of variables in persistent flash memory that guides it to boot either original or custom firmware.  Those variables can be set/modified by interacting with the u-boot console using the `setenv` command and made persistant by using `savenv`. Alternatively, it's also possible to access the persistant storage of u-boot variables from a running Debian Linux image (see below).</br>  Some variables:</br>
- __ipaddr__: the IP address of your WBL NAS when booting into u-boot boot loader
- __serverip__: the default IP address of the BOOTP/TFTP server (172.25.102.35)
- __hostname__: the default hostname (apollo3g)
- __bootargs__: the default boot arguments passed on to the kernel
- __load_boot_file_1__: the default boot file /boot/boot.scr

Below you will information on how to customize these variables and control the way your boots by modifying the _/boot/boot.scr_ file


## Introduction to safe/recovery kernels ##

It has happened to me many times: a newly build kernel does not boot! Or, hundreds of debug messages are flooding the screen and make it impossible to restore a proper config. A safe/recovery kernel allows to simply pull the plug (or wait for u-boot watch-dog to triger a restart) and have u-boot boot a safe/recovery kernel.  The trick is to keep a _boot_count_ u-boot variable which is incremented at each boot but reset by /etc/rc.local at successful boot of the new kernel.   


## Introduction to netconsole ##
First read about netconsole here: https://www.kernel.org/doc/Documentation/networking/netconsole.txt

The WD MBL netconsole implementation requires the following:
- netconsole enabled uboot files
- netconsole enabled kernel
- netconsole enabled Linux kernel patches and config file (if you want to compile your own kernel)

DO NOT TEST THIS WITHOUT ABILITY TO TAKE YOUR DRIVE OUT AND HOOK TO A LINUX SYSTEM

## What is "double" netconsole and why use it? ##
Double netconsole allows you to both
- view (or, on Linux and Windows, interact with) the u-boot console
- view (or, on Linux, interact with) the systems console

In this way one can view boot errors, kernel boot errors as well as console messages. 
The biggest advantages of double netconsole are:
- no more need to solder a UART (using non standard pin header) and risk damaging your MBL
- no more need to open up your MBL (which is a nerve-racking exercise for many)
- no need for (messy) cables
- ability to monitor boot and interact with MBL u-boot remotely

## Building a kernel with netconsole support ##
On WD MBL platforms this requires both a patch as well as enabling netconsole in the kernel.
Read [here](https://github.com/ewaldc/My-Book-Live/tree/master/kernel) to build your own My Book Live kernel, optionally via cross-compilation.

Alternatively, __choose the easy route__ and download a precompiled, netconsole-enabled kernel [here](https://github.com/ewaldc/My-Book-Live/tree/master/kernel)


## Building u-boot boot file using netconsole ##

u-boot is looking for a boot file called `/boot/boot.scr`

generate with
```
./mkBootSrc.sh boot_recovery_netconsole
cp boot_recovery_netconsole.scr boot.scr
cp boot.scr /boot
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

Then create your boot file by customizing the u-boot template file [boot_recovery_netconsole.txt](https://github.com/ewaldc/My-Book-Live/blob/master/uboot/boot_recovery_netconsole.txt) which supports two netconsole windows and two network cards. Feel free to simplify.

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

Define linux kernel boot arguments, including support for TFTP booting and kernel/u-boot netconsole. Remove ipv6.disable=1 if you want ipv6. There is also a "debugargs" if you want to enable more kernel debug info.

```
setenv bootargs 'root=/dev/sda2 earlycon earlyprintk rw rootfstype=ext4 rootflags=data=ordered ipv6.disable=1'
setenv debugargs 'setenv bootargs debug rootdelay=5 panic=10 debug ignore_loglevel log_buf_len=1M ${bootargs}'
setenv bootargs_lan 'setenv bootargs netconsole=6663@${ipaddr}/,6664@${ncIPLan}/${ncMacLan} ${bootargs}'
setenv bootargs_wlan 'setenv bootargs netconsole=6663@${ipaddr}/,6664@${ncIPWLan}/${ncMacWLan} ${bootargs}'
setenv load_sata 'sata init; ext2load sata 1:1 ${kernel_addr_r} /boot/uImage; ext2load sata 1:1 ${fdt_addr_r} /boot/apollo3g.dtb'
setenv load_sata_rcvr 'sata init; ext2load sata 1:1 ${kernel_addr_r} /boot/uImage.safe; ext2load sata 1:1 ${fdt_addr_r} /boot/apollo3g.safe.dtb'
setenv load_tftp 'tftp ${kernel_addr_r} ${bootfile}; tftp ${fdt_addr_r} ${fdt_file}'
setenv boot_kernel 'run bootargs_lan addtty; bootm ${kernel_addr_r} - ${fdt_addr_r}'
```

Print all u-boot variables (mostly for debugging):

`printenv`

If _boot_count_ == 2 then load recovery kernel, else load default kernel:
```
if itest ${boot_count} == 1; then echo "=== Loading Default Kernel ==="; run load_sata1; else echo "=== Loading Recovery Kernel ==="; run load_sata2; fi
run boot_sata
```

## TFTP Boot ##

Network booting requires `initramfs` to be included in the kernel. Please read the section on [initramfs](https://github.com/ewaldc/My-Book-Live/tree/master/kernel/initramfs).

customize as above and generate with
```
./mkBootSrc.sh boot_tftp_recovery_netconsole
cp boot_tftp_recovery_netconsole.scr boot.scr
cp boot.scr /boot
EOF
```

On the TFTP-server, create a folder called `apollo3g` and copy `uImage` and `apollo3g.dtb` and/or `apollo3g_dou.dtb` to this directory.


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

In this way a running operation system can feed back to u-boot that booting has successfully completed and there is no need to try a fallback boot image.  Additionally, it could fallback on TFTP/BOOTP boot.
For this to work add following lines to `/etc/rc.local`:
```
# Reset boot_counter after succesfull boot
fw_setenv boot_count 0
```


## Netcat for Linux and Windows ##

Netcat is one of the easiest ways to visualize both uboot consoles (ports 6664 an 6666).
Netcat on Linux is standard (nc command).
For Windows, I have provided a portable version.

See [NetCatWindows.z](https://github.com/ewaldc/My-Book-Live/blob/master/uboot/NetCatWindows.7z)

Start two nc windows: `netconsole.bat` and `uboot_neconsole.bat`.
These Windows batch files also provide hints of how to run this on Linux. 