#!/bin/sh

set -e

LD_LIBRARY_PATH=/home/user/work/mini/src/work/tmp_rootfs/lib go build .
sudo LD_LIBRARY_PATH=/home/user/work/mini/src/work/tmp_rootfs/lib:$LD_LIBRARY_PATH lddtree ./ldr -b /media/sf_work/bcd_disk-s /dev/nbd0p2