#!/bin/bash
set -e

# pushd ./minimal_overlay/bundles/ldr-service
# go build .
# popd
# cp -rf ./minimal_overlay/bundles/ldr-service/ldr ./work/overlay_rootfs/bin/ldr

pushd /media/sf_work/hloader/
go build -buildvcs=false . 
popd
cp -rf /media/sf_work/hloader/hloader ./work/overlay_rootfs/bin/hloader
./09_generate_rootfs.sh
./10_pack_rootfs.sh
#cp -rf ./work/rootfs.cpio.xz ~/work/pxe/root/rootfs.xz
cp -rf ./work/kernel/kernel_installed/kernel /media/sf_work/root/kernel.xz
cp -rf ./work/rootfs.cpio.xz /media/sf_work/root/rootfs.xz
