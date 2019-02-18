# Installing My-Book-Live pre-compiled kernels

## Which kernel to take ? ##

All kernels listed below here have survived a 96-hours torture test.  Other kernels posted versions are not fully validated (yet).  Anyhow, none of them are officially supported, so this is __always at your own risk__.

## Validated kernels ##
* 4.9.77: this kernel is part of the posted Debian Jessie 8.11 image and extremely stable
* 4.9.99: with netconsole
* 4.9.119_hdd_led: first kernel to include hard disk activity led patch, with netconsole. First 4.9.1xx kernel to have survived the 96 hour torture test due to a defect that was introduced probably in 4.9.10[1234]. 
* 4.9.135: streamlined config (e.g. less performance counters, more functions pushed to modules) resulting in smaller size kernel
* 4.9.149: comes in two configurations : optimized for space and optimized for performance which is ~400K larger.  In reality though there is not much performance difference...

## Installing pre-build kernels ##
All posted kernels are compressed tar archives with [7zip](https://www.7-zip.org/) and contain:
* /boot/apollo3g.dtb:  compiled device tree compatible with kernel
* /boot/uImage_4.9.xx: compiled/compressed kernel
* /lib/modules/4.9.xx: compile kernel modules

_First make sure you have a backup of your current `/boot/apollo3g.dtb' and kernel `/boot/uImage`_.<br>
Copy the uncompressed tar file to `/tmp` of My Book Live, extract the archive, enable the new kernel and reboot:<br>
```
cd /
tar -xzf /tmp/linux-4.9.135.tgz
cp /boot/uImage_4.9.135 /boot/uImage
systemctl reboot
```
