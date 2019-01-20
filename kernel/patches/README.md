# My-Book-Live kernels

## Which kernel to build ? ##

We have build 2.x, 3x and 4.x kernels but ultimately there is only one top level choice to make:
* I want to keep the original OEM software because of it's web user interface and vendor support: in that case the only custom kernel available is 2.6.32.70/71.  You will find the patch in source code [here](https://github.com/ewaldc/My-Book-Live/tree/master/kernel/patches/2.6.32)
* I would like to run a more recent version of Debian than the Debian 6 (Lenny) version that comes with the original Western Digital firmware (e.g. for security or recent package support reasons).
	* Debian 7 (Wheezy):  run custom kernel 2.6.32.70/71, more recent versions won't boot without extensive changes to kernel code (3.x, 4.x).  It's possible though, but it makes little sense IMHO for support and performance reasons (contact me if your feel different)
	* Debian 8 (Jessie):  all 4.x kernels work
		
	
## Which kernel provides the highest level of performance ? ##

Nothings beats Debian Wheezy and custom kernel 2.6.32.70/71 with page size of 64K, network MTU size of 4088 and root/user filesystem with block size of 64K
* Sequential disk reads of 180MB/s (dd if=tst.dd of=/dev/null bs=1M count=1K)
* Sequential disk writes of 110MB/s (dd if=/dev/zero of=tst.dd  bs=1M count=1K)
* Samba read speed of 122 MB/s (1GB file read, Windows 10 64-bit)
* Samba write speed of 118 MB/s (1GB file write, Windows 10 64-bit)

The main reasons for this are:
* The custom 2.6.32.70/71 kernel has support for DMA, splice with DMA, modification to standard Linux network stack, NCQ data support, support for MSI, OCM, TAH, MAL, hardware TSO (checksum offloading),  Interrupt Coalescing, SYSFS, Mask Carrier Extension signals, Powerdown mode, WOL (wake on LAN) support, Broadcom NIC 54610 tuning etc.
* Kernel 2.6.x is lean and mean and does small and fast
* Debian Lennie/Wheezy are relatively simple and close to system V unix
* Debian Jessie is clearly a newer generation Linux: very stable but bigger, highly functional at the expense of more baseline processes and more memory consumption.  It's also more complex to administer (e.g. system.d)
* More recent kernels have grown in size (e.g. due to more common code) and complexity.  While powerPC 32 is still supported, general code is more optimized and tested for modern, 64-bit architectures.  Hence, with each new release, the amount of patches needed to make things work reliably and at comparable performance is growing. 
