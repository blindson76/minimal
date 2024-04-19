#!/bin/bash
set -e
pushd ./minimal_overlay/bundles/ldr-service
go build hello.go
popd
cp -rf ./minimal_overlay/bundles/ldr-service/hello ./work/overlay_rootfs/bin/hello
./09_generate_rootfs.sh
./10_pack_rootfs.sh
cp -rf ./work/rootfs.cpio.xz ~/work/pxe/root/rootfs.xz
