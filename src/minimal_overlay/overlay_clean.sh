#!/bin/sh

set -e

SRC_DIR=$(pwd)

echo "Cleaning up the overlay work area. This may take a while."
rm -rf ../work/overlay
rm -rf ../work/overlay_rootfs
rm -rf ../work/tmp_rootfs

# -p stops errors if the directory already exists.
mkdir -p ../work/overlay
mkdir -p ../work/overlay_rootfs/bin
mkdir -p ../work/overlay_rootfs/lib
mkdir -p ../work/tmp_rootfs
mkdir -p ../source/overlay

echo "Ready to continue with the overlay software."

cd $SRC_DIR
