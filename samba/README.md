# My-Book-Live SAMBA
The standard Samba version which is inlcuded on the provided Debian 8.11 image is 4.2.14-Debian.

This relative modern version provides good performance with modern versions of Linux and Windows.
When used with the provided config files to be place in /etc/samba, one can expect results in the neighboorhood of :

* Samba read speed of ~100 MB/s (1GB file read, Windows 10 64-bit)
* Samba write speed of ~80 MB/s (1GB file write, Windows 10 64-bit)

When compiling and tuning SAMBA 4.9.x, it's possible to achieve slightly higher values:

* Samba read speed of ~115 MB/s (1GB file read, Windows 10 64-bit)
* Samba write speed of ~85 MB/s (1GB file write, Windows 10 64-bit)


When given the time, I will post the patches and instructions of how to cross-compile SAMBA.
This code has run for many months without a single failure, and passed 96 hour torture test.

# Experimental
With the DMA driver and patched splice.c/pipe.c, it's possible to achieve:

* Samba read speed of ~120 MB/s (1GB file read, Windows 10 64-bit)
* Samba write speed of ~95 MB/s (1GB file write, Windows 10 64-bit)

However, this code has not passed the tests and leaks memory.