#!/bin/sh
if [ "$#" -lt 1 ]; then
  echo "usage $0 <source file without .txt extension> --> generates .scr"
  exit 1
fi
mkimage -A powerpc -O linux -T script -C none -a 0 -e 0 -n 'Execute uImage' -d $1.txt $1.scr
chmod 744 $1.scr

mount /dev/sda1 /mnt
cp -f $1.scr /mnt/boot

if [ "$2" = "-install" ] 
then
  rm -f /mnt/boot/boot.scr
  ln /mnt/boot/$1.scr /mnt/boot/boot.scr
  ls -l /mnt/boot
fi

umount /mnt
