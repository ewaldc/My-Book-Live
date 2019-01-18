# My-Book-Live
Kernel patches and Debian release for Western Digital My Book Live
## Debian Jessie 8.11 optimized for MyBookLive: ##


* Debian 8.11 with security patches backported to PowerPC
* MiniDLNA (e.g. for access from Smart TV’s)
* Rsync 3.1.3 modified to use Kernel Crypto API
* Libkcapi + executables (Kernel Crypto API access from user space)
* packages to compile and profile kernels
* kernel 4.9.99 pre-compiled, updated DTB
* SAMBA patched for performance

Installation instructions [here](https://drive.google.com/open?id=1xaSLBwQVS4h4scVBxDGTdkvvZ8WYBfLE)<br /> 
Compressed tar archive [here](https://drive.google.com/open?id=1JIxsm7rw0dInq5XE2C5nBjtVbGqGfVes)


## Reading and writing u-boot environment flash from Debian Jessie ##
How to avoid opening the My Book Live shell in case a boot failure:
* (low-level) format the embedded hard drive
* u-boot fails to boot from harddisk 

One of the requirements to make this all work is the ability to read/write the u-boot environment stored in nor flash from the OS, which is stored within /dev/mtd0.

First install u-boot-tools:
`apt-get install u-boot-tools`

Then create /etc/fw_env.config:

`cat >/etc/fw_env.config <<EOF`<br />
`/dev/mtd0 0x1e000 0x1000 0x1000 1`<br /> 
`/dev/mtd0 0x1f000 0x1000 0x1000 1`<br /> 
`EOF`

Now you can check your environment: 
`fw_printenv`
And set a variable: 
`fw_setenv variable value`

In this way a running operation system can feedback to u-boot that booting has successfully completed and there is no need to try a fallback boot image.  Additionally, it could fallback on TFTP/BOOTP boot.
