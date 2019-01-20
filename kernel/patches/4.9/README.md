# My-Book-Live kernel 4.9.x

## Validated versions ##
There is a reasonable chance these patches work with any 4.9.x version.
However, practical experience has shown that not every version is equally stable and/or performing.
Following versions have been validated as "excellent":
* 4.9.33
* 4.9.44
* 4.9.77
* 4.9.99
* 4.9.119
* 4.9.135

Pre-4.9.31 versions are to be avoided for stability reasons. Versions post 4.9.135 are most likely fine.
Current version under test: 4.9.149

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
Install all the tools required for kernel building and creation of the u-boot bootloader entrypoint.<br>
`apt-get install ca-certificates build-essential uboot-mkimage ncurses-dev unzip`

Download the 4.9 kernel of your choice:
* using github: https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git.  For example clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/?h=v4.9.149
* download the latest compressed tarball: https://www.kernel.org/
* download a version of your choice in compressed tar format (gz or xz, xz preferred as it is the smaller size): https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/

Uncompress the kernel:
* in .gz format: `tar -xzf linux-4.9.149.tar.gz`
* in .xz format: `tar -xJf linux-4.9.149.tar.xz`

Change active directory: `cd linux-4.9.149`<br>
Optionaly, save some disk space by deleting uneeded architectures:
```
cd arch
rm -rf [a-j]*; rm -rf [l-o]*; rm -rf parisc unicore32 xtensa
rm -rf [s-t]*; rm -rf x86/[a-c]* x86/events x86/[f-p]* x86/[t-x]* x86/realmode
cd ..
```

Make patch directory: `mkdir patches`<br>
Download [patches](https://github.com/ewaldc/My-Book-Live/blob/master/kernel/patches/4.9/patches/patches.7z) and extract to the patches directory.  Apply the patches:
```  
for i in $(ls patches/[0-9]*)
do
  echo "#### $i ####"
  patch -p 1 -b -i $i
done
```

Watch for any failed patches. Please accept my apologies if you hit an error and submit an issue...

Copy one of the sample confg files from [here](https://github.com/ewaldc/My-Book-Live/tree/master/kernel/patches/4.9/config) and duplicate as .confg:<br>
`cp config_netconsole_4.9.149 .config`

Build the kernel:<br>
`make uimage`


## Kernel 4.9.x performance ##
With a 4.9.x customer kernel, standard 4K block size ext4 file system, Debian 8.11, page size of 64K, network MTU size of 4088, one can expect:
* Sequential disk reads of 170MB/s (dd if=tst.dd of=/dev/null bs=1M count=1K)
* Sequential disk writes of 100MB/s (dd if=/dev/zero of=tst.dd  bs=1M count=1K)
* Samba read speed of 116 MB/s (1GB file read, Windows 10 64-bit)
* Samba write speed of 85 MB/s (1GB file write, Windows 10 64-bit)
* over 400 days of uptime as measured on a My Book Live NAS used in a muti-user production environment

## Supportability ##
At this point in time, __no other 4.x kernel will have a longer support life than 4.9__