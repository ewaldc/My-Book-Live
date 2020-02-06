# Installing My-Book-Live pre-compiled kernels

## Before you install a different kernel ##
First, read up on how to enable a recovery kernel __[here](https://github.com/ewaldc/My-Book-Live/tree/master/uboot)__. A safe or recovery kernel allows for fail-back to a known, good kernel in case something goes wrong. 

## Which kernel to take ? ##

All kernels listed below here have survived a 96-hours torture test.  Other kernels posted versions are not fully validated (yet).  Anyhow, none of them are officially supported, so this is __always at your own risk__.
The only kernel that can be used with original WD software is 2.6.32.70.

## Validated kernels for use with OEM/original firmware ##
The only tested, pre-compiled kernel which is supported by Debian Lenny as included with the original firmware is 2.6.32.70.<br>
Install as follows (for MBL):
```
cd /
tar -xzf /tmp/kernel-2.6.32.70-ncq.tgz
mv /boot/uImage /boot/uImage.safe
cp /boot/uImage.2.6.32.70.64K_NCQ /boot/uImage
```

For MBL Duo use uImage.2.6.32.70.64K_NCQ_DUO.
There are no custom /boot/apollo3g.dtb files, the 2.6.32.70 kernel will use the original device tree files for ease of installation, both for duo and solo.
You will need to update `/etc/network/if-up.d/tuneperf` to use Jumbo packets or alternatively just delete it to use regular MTU of 1500.


## Validated kernels for use with custom images based on Debian Jessie ##
* 4.9.77: this kernel is part of the posted Debian Jessie 8.11 image and extremely stable
* 4.9.99: with netconsole
* 4.9.119_hdd_led: first kernel to include hard disk activity led patch, with netconsole. First 4.9.1xx kernel to have survived the 96 hour torture test due to a defect that was introduced probably in 4.9.10[1234]. 
* 4.9.135: streamlined config (e.g. less performance counters, more functions pushed to modules) resulting in smaller size kernel
* 4.9.149: comes in three configurations : optimized for space, optimized for performance which is ~400K larger and a version of the latter which includes IO accounting (allows to run `iotop`).  In practical use though there is not much performance difference...
* 4.19.99: high performance kernel released with patches

## Installing pre-build kernels on Debian Jessie ##
All posted kernels are compressed tar archives with [7zip](https://www.7-zip.org/) and contain:
* /boot/apollo3g.dtb:  compiled device tree compatible with kernel
* /boot/uImage_4.9.xx: compiled/compressed kernel
* /lib/modules/4.9.xx: compiled kernel modules

First, __make sure you have a backup__ of your current `/boot/apollo3g.dtb` and kernel `/boot/uImage`.<br>
Or, better, enable recovery kernels and move your working kernel and dtb file to `/boot/uImage.safe` and `/boot/apollo3g.safe.dtb` (or `/boot/apollo3g_duo.safe.dtb` for MBL DUO).
Copy the uncompressed tar file to `/tmp` of My Book Live, extract the archive, enable the new kernel and reboot:<br>
```
cd /
tar -xzf /tmp/linux-4.9.135.tgz
cp /boot/uImage_4.9.135 /boot/uImage
systemctl reboot
```

Please note that the __swap space must match the kernel block size__. So, if the new kernel has a different page size than the previous one, you need to re-initialize swap space.  Assuming the standard MBL disk layout, swap space is on `/dev/sda3`.  The `mkswap` command will read the kernel page size, so no need to pass the `--pagesize` option.  Since 4.9.x and 4.19.x have different page sizes (for now), 64K and 16K respectively, this issue will arise as you swap kernels.

```
mkswap /dev/sda3
```
