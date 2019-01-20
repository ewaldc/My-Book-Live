# My-Book-Live kernel 4.9.x

## What's included ##
The latest version of the patches include:
* sata driver with NCQ support (disabled by default since it provided no extra performance on 4.9)
* support for MSI, OCM
* tuned Broadcom NIC 54610 network driver: jumbo packets, TCP/IP Acceleration Hardware (TAH) support, MAL enhancements, hardware TSO (checksum offloading), Interrupt Coalescing, SYSFS support, Mask Carrier Extension signals, Powerdown mode, WOL (wake on LAN) support, etc.
* hard disc led activity support
* USB driver with DMA support
* fix for 64K page size
* optimized compilation (AMCC 464fp)
* patches from OpenWRT team
* netconsole support patch
* Linux Skbuff performance tuning

## Building the kernel ##
In our chroot, we now install all the tools we require for kernel building and creation of th eu-boot bootloader entrypoint.<br>
`apt-get install ca-certificates build-essential uboot-mkimage ncurses-dev unzip`



## Kernel 4.9.x performance ##
With a 4.9.x customer kernel, standard 4K block size ext4 file system, Debian 8.11, page size of 64K, network MTU size of 4088, one can expect:
* Sequential disk reads of 170MB/s (dd if=tst.dd of=/dev/null bs=1M count=1K)
* Sequential disk writes of 100MB/s (dd if=/dev/zero of=tst.dd  bs=1M count=1K)
* Samba read speed of 116 MB/s (1GB file read, Windows 10 64-bit)
* Samba write speed of 85 MB/s (1GB file write, Windows 10 64-bit)
* over 400 days of uptime as measured on a My Book Live NAS used in a muti-user production environment

## Supportability ##
At this point in time, __no other 4.x kernel will have a longer support life than 4.9__