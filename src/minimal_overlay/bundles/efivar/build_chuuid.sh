#!/bin/sh

set -e

. ../../common.sh
#echo $TMP_ROOTFS
gcc -L$TMP_ROOTFS/lib -lhivex -I$TMP_ROOTFS/include -I$TMP_ROOTFS/usr/include -o chuuid chuuid.c
