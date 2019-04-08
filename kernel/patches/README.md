# Building My-Book-Live kernels

## Which kernel to build ? ##

We have build 2.x, 3x and 4.x kernels but ultimately there is only one top level choice to make:
* _"I want to keep the original OEM software because of it's web user interface and vendor support"_<br>In that case the only custom kernel available is 2.6.32.70/71.  You will find the patch in source code [here](https://github.com/ewaldc/My-Book-Live/tree/master/kernel/patches/2.6.32).  It will provide a considerable performance improvement over standard software, up to 2x on certain tests.
* _"I would like to run a more recent version of Debian than the Debian 6 (Lenny) version that comes with the original Western Digital firmware (e.g. for security or recent package support reasons)"_.  You have two choices:
	* Debian 7 (Wheezy):  run custom kernel 2.6.32.70/71, more recent versions won't boot without extensive changes to kernel code (3.x, 4.x).  It's possible though, but it makes little sense IMHO for support and performance reasons (contact me if your feel different)
	* Debian 8 (Jessie):  all 4.x kernels work, kernel 2.6.x won't boot
		
	
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

But there are also reasons to consider other alternatives:
* The desire of many users to opt for recent operating systems and kernels for support and security reasons
* Jumbo frame support in Linux 2.6.32.7x is not totally stable.  It needs a watchdog to reset the LAN when it hangs.  However, the kernel has stayed up for more than year under stress with almost no memory leakage
* Having a root and/or user filesystem with 64K block size makes it virtually unreadable on other Linux systems.  There is a general willingness to give up some performance for better flexibility and portability.

At this moment, the most performant, up-to-date and fully supported Linux 4.x kernel is 4.9.  It's a kernel with extended support life (LTS) and the best balance between size and supportability.  Please note that at this moment no other active kernel  kernel has a longer support life according to Greg Kroah-Hartman on this releases [page](https://www.kernel.org/releases.html)

With a 4.9.x customer kernel, standard 4K filesystem block size ext4 file system, Debian 8.11, page size of 64K, network MTU size of 4080, one can expect:
* Sequential disk reads of 160MB/s (dd if=tst.dd of=/dev/null bs=1M count=1K)
* Sequential disk writes of 140MB/s (dd if=/dev/zero of=tst.dd  bs=1M count=1K)
* Samba read speed of 110 MB/s (1GB file read, Windows 10 64-bit)
* Samba write speed of 75 MB/s (1GB file write, Windows 10 64-bit)
* over 400 days of uptime as measured on a My Book Live NAS used in a muti-user production environment

## New development - how about newer 4.x kernel releases ? ##

Since My Book Live is based on a 2009 PowerPC 32-bit architecture, it makes no sense to focus on kernels that are not Long Term Support releases.  That limits the choice for newer kernels to 4.14 and 4.19 (as of now).

Kernel 4.14 has some nice new functions but requires many patches (just take a look at OpenWRT team patches for 18.06.1 for just about any router). Despite all the patches, tremendoes work from the OpenWRT team, I have not been able to keep this kernel running for more than a week under torture test.  At this moment 4.19 is the most promising kernel, but it will requires substantional amounts of work to get everything ported. Performance-wise it might be at par with 4.9.x given some extra tuning.   

In the 4.19 folder, you will find the second released patch set for 4.19 which delivers suberb performance and survives 96 hours of torture (validated for 4.19.24) test with no (major) memory leak.

Initial testing of 4.20 delivers even better performance than 4.19 !
Linux kernel 5.0 was a challenge to compile, has weaker performance and did not survive 8 hours of testing.

Things under consideration and/or under development:
* DMA hardware support - status: succesful tests completed
* huge page support - status : very complex, keeps failing... 
* update standard 4.19 drivers with more custom hardware enablement (e.g. continuous buffer mode for network and sata drivers) - status : 90% done for 4.19
* DMA splice, user-to-user space splice.  Prototype code achieved 122 MB/s SAMBA write! - status : not yet stable
* more crypto HW acceleration - status : early proto
* Samba 4.10 cross compile + custom tuning - status : not started
* Recompile some Debian executables to leverage capabilities of the new kernels
* Enable powerpc kernel debugging and profiling (done) and code powerpc 32 branch tracing (complex)
* Fix ext4 code paths (ext4 has been slowing down since 3.18, about 15%) - status : being lazy and waiting for 5.x cleanup work
* NCQ support - status : investigation

Ultimately, at this point in time, __no other 4.x kernel will have a longer support life than 4.9__