#!/bin/bash
set -e
# pushd ./minimal_overlay/bundles/ldr-service
# go build .
# popd
# cp -rf ./minimal_overlay/bundles/ldr-service/ldr ./work/overlay_rootfs/bin/ldr

HLOADER_PATH=/mnt/d/work/hloader
CP_PATH=/mnt/d/work/root/
pushd $HLOADER_PATH
./build.sh 
popd
cp -rf $HLOADER_PATH/hloader ./work/overlay_rootfs/bin/hloader
./09_generate_rootfs.sh
./10_pack_rootfs.sh
#cp -rf ./work/rootfs.cpio.xz ~/work/pxe/root/rootfs.xz
cp -rf ./work/kernel/kernel_installed/kernel $CP_PATH/kernel.xz
cp -rf ./work/rootfs.cpio.xz $CP_PATH/rootfs.xz
