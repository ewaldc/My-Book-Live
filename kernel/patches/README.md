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
* Kernel 2.6.x is lean and mean, hence small and fast
* Debian 6 (Lenny) and 7 (Wheezy) are relatively simple and close to system V unix
* Debian Jessie is clearly a newer generation Linux: very stable but bigger, highly functional at the expense of more baseline processes and more memory consumption.  It's also more complex to administer (e.g. system.d)
* More recent kernels have grown in size (e.g. due to more common code) and complexity.  While PowerPC 32 is still supported, general code is more optimized and tested for modern, 64-bit architectures.  Hence, with each new release, the amount of patches needed to make things work reliably and at comparable performance is growing. 

But there are also some disadvantages
* The desire of many users to run operating systems and kernels for support and security reasons
* Jumbo frame support in Linux 2.6.32.7x is not totally stable.  It needs a watchdog to reset the LAN when it hangs.  However, the kernel has stayed up for more than year under stress with almost no memory leak
* Having a root and/or user filesystem with 64K block size makes it virtually unreadable on other Linux systems.  There is willingness to give up some performance for flexibility and portability

At this moment, the most performant Linux 4.x kernel is 4.9.  It's a kernel with extended support life (LTS) and the best balance between size and supportability.  Please note that at this moment no other active kernel  kernel has a longer support life according to Greg Kroah-Hartman on this releases [page](https://www.kernel.org/releases.html)

With a 4.9.x customer kernel, standard 4K ext4 file system, Debian 8.11, page size of 64K, network MTU size of 4088, one can expect:
* Sequential disk reads of 170MB/s (dd if=tst.dd of=/dev/null bs=1M count=1K)
* Sequential disk writes of 100MB/s (dd if=/dev/zero of=tst.dd  bs=1M count=1K)
* Samba read speed of 116 MB/s (1GB file read, Windows 10 64-bit)
* Samba write speed of 85 MB/s (1GB file write, Windows 10 64-bit)
* over 400 days of uptime as measure on our production NAS

## New development - how about newer 4.x kernel releases ? ##

Since My Book Live is based on a 2009 32-bit architecture, it makes no sense to focus on kernels that are not Long Term Support releases.  That limits the choice to 4.14 and 4.19.

Kernel 4.14 has some nice new functions but requires many patches (just take a look at OpenWRT team patches for 18.06.1 for just about any router). Despite all the patches, tremendoes work from the OpenWRT team, I have not been able to keep this kernel running for more than a week under torture test.  Performance-wise it mostly under-performs 4.9.x.   At this moment 4.19 is the most promising kernel.

Another development route is to further tune 4.9 performance and bring in new functions like:
* DMA hardware support
* huge page support
* update standard 4.9 drivers with my custom hardware enablement (e.g. network and sata drivers)
* DMA splice, user-to-user splice.  Prototype code achieved 122 MB/s SAMBA write!
* more crypto HW acceleration

Ultimately, at this point in time, __no other 4.x kernel will have a longer support life than 4.9__