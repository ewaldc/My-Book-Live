# My-Book-Live cross-compiling kernels

The easiest way to cross compile the kernel on a Linux system is to use the [OpenWrt build system](https://openwrt.org/docs/guide-developer/build-system/use-buildsystem) or the [OpenWrt Image Builder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder).  The OpenWRT build systems are based on [MUSL](https://musl.cc/).  From the MUSL site you can download both native PowerPC (for us on the MBL itself) and cross-compilation packages (for use on x86/x64 Linux server) for GCC 6,7,8 or 9.
In addition, most Linux systems have prebuild packages for PowerPC cross compilers.
Alternatively, you can use the posted precompiled version of the toolchain version 8.3 for Debian/Ubuntu 64-bit.
I have used all of these with good success.

You can download the Image Builder for the APM821xx [here](https://downloads.openwrt.org/snapshots/targets/apm821xx/sata/)


## Cross-compiling the kernel

To simply compile the kernel, leverage the `xkmake` script.
You need to customize the location of the toolchain.

For a full script that compiles the kernel, modules and transfers everything back to My Book Live, leverage `xkbuild`.
You need to customize the location of the toolchain and the name of your NAS.
Additionally you need to enable ssh and sftp to automatically log in your NAS as root.

On a 4-core CPU with SSD, it takes less then 1 minute to fully compile the kernel and about 2 seconds to update a single source file.
