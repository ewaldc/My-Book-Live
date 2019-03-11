# My-Book-Live kernel 4.19.x

## Validated versions ##
There is a reasonable chance these patches work with any 4.19.x version newer than 4.19.24.
However, practical experience has shown that not every version is equally stable and/or performing.
Following versions have been validated as "excellent":
* 4.19.24
* 4.19.25

Pre-4.19.19 versions are to be avoided for stability reasons. Versions post 4.19.25 are most likely fine.
Last version validated: 4.19.25

## What's changed compared to 4.9.x ? ##
The DesignWare (DW) DMA and SATA driver code have evolved to levels of performance that are close enough to the custom SATA DWC NCQ driver to discontinue it.  All the credit for this work goes to the OpenWRT team (chunkeey). However, there is plenty of room for further tuning of these drivers and some of the code of the SATA DWC NCQ driver will be integrated.  The OpenWRT team will be able to pick up this work if they desire so.

One disadvantage of using the DW DMA and SATA drivers is the fact that they don't work with 64K page sizes due to a defect, so the kernel has to be compiled with 4K or 16 page sizes.  Given time, I wil will fix the code, but 16K page size delivers decent performance for now and consumes less memory.
Are also being dropped: custom USB and led drivers.


In addition, this allow to fully leverage the device tree source (DTS) from OpenWRT.
The EMAC driver and skbuff patches are still unique and deliver 15%+ performance over the OpenWRT ones, which for NAS functionality is noticable. 


## What's included ##
The latest version of the patches include:
* support for MSI, OCM
* tuned Broadcom NIC 54610 network driver: jumbo packets, TCP/IP Acceleration Hardware (TAH) support, MAL enhancements, hardware TSO (checksum offloading), Interrupt Coalescing, SYSFS support, Mask Carrier Extension signals, Powerdown mode, WOL (wake on LAN) support, etc.
* hard disc led activity support
* USB driver with DMA support
* optimized compilation (AMCC 464fp)
* patches from OpenWRT team
* netconsole support patch
* Linux Skbuff performance tuning
* MAL instance allocted to OCM
* 16K Kernel Page Size (instead of 64K)


## Building the kernel ##
Install all the tools required for kernel building and creation of the u-boot bootloader entrypoint.<br>
`apt-get install ca-certificates build-essential uboot-mkimage ncurses-dev unzip`

If you are using Windows, make sure you have tools to log into the My Book Live and copy files.
My favorites are [kitty](http://www.9bis.net/kitty/) (a portable fork of putty which auto-reconnects after a reboot) and [WinSCP](https://winscp.net/eng/download.php)
 
Download the 4.19 kernel of your choice:
* using github: https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git.  For example clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/?h=v4.19.24
* download the latest compressed tarball: https://www.kernel.org/
* download a version of your choice in compressed tar format (gz or xz, xz preferred as it is the smaller size): https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/

Uncompress the kernel:
* in .gz format: `tar -xzf linux-4.19.24.tar.gz`
* in .xz format: `tar -xJf linux-4.19.24.tar.xz`

Change active directory: `cd linux-4.9.149`<br>
Optionaly, save some disk space by deleting uneeded architectures:
```
cd arch
rm -rf [a-j]*; rm -rf [l-o]*; rm -rf parisc unicore32 xtensa
rm -rf [s-t]*; rm -rf x86/[a-c]* x86/events x86/[f-p]* x86/[t-x]* x86/realmode
cd ..
```

Make patch directory: `mkdir patches`<br>
Download [patches](https://github.com/ewaldc/My-Book-Live/blob/master/kernel/patches/4.19/patches/patches.7z) , extract to the patches directory and apply:
```  
for i in $(ls patches/[0-9]*)
do
  echo "#### $i ####"  
  patch -p 1 -b -i $i
done
```

Watch for any failed patches. Please accept my apologies if you hit an error and submit an issue...

Copy one of the sample config files from [here](https://github.com/ewaldc/My-Book-Live/tree/master/kernel/patches/4.19/config) and duplicate as .config. Alternative build your own config file using `make menuconfig`:<br>
`cp config.4.19 .config`

Build the kernel, resolve some potentional config file questions, and ... get a coffee/beer:<br>
`make uImage`

Build the modules:<br>
`make modules; make modules_install`

Copy the kernel and modules:<br>
```
export KERNEL_VERSION=$(echo $PWD|cut -d"-" -f 2)
cp arch/powerpc/boot/uImage /boot/uImage_$KERNEL_VERSION
```

Now you have succesfully build the kernel, keep in mind that none of these kernels are officially supported, so what follows is __always at your own risk__.

Make sure your `/boot/boot.scr` and `/boot/apollo3g.dtb` are compatible with the new kernel, which for 4.19 is different than 4.9 !<br>
Put new kernel in place, make sure you have copied the original one:<br> 
```
mv /boot/uImage /boot/uImage.bck
ln /boot/uImage_$KERNEL_VERSION /boot/uImage
```

Reboot, make sure your netconsole windows are ready and ... good luck:<br>
`systemctl reboot`


## Kernel 4.19.x performance ##
With a 4.19.x customer kernel, standard 4K block size ext4 file system, Debian 8.11, page size of 16K, network MTU size of 4080, one can expect:
* Sequential disk reads of 121MB/s (dd if=tst.dd of=/dev/null bs=4k count=256K)
* Sequential disk writes of 120MB/s to 160MB/s (dd if=/dev/zero of=tst.dd bs=1M or 4K)
* Samba read speed of 110 MB/s (1GB file read, Windows 10 64-bit)
* Samba write speed of 75 MB/s (1GB file write, Windows 10 64-bit)
* over 400 days of uptime as measured on a My Book Live NAS used in a muti-user production environment

## Supportability ##
Kernel 4.19 series are Long Term Support (LTS) releases and very recent, so a long support live is ahead of us.

However. at this point in time, __no other 4.x kernel will have a longer support life than 4.9__
