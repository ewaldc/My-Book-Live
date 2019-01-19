#!/bin/sh
if [ "$#" -ne 2 ]; then
  echo "usage $0 <source text file> <destination boot.scr.file>"
  exit 1
fi
mkimage -A powerpc -O linux -T script -C none -a 0 -e 0 -n 'Execute uImage' -d $1 $2
