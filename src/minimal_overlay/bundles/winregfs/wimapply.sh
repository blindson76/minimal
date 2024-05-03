#!/bin/bash

mkdir -p /esp
mkdir -p /reg

umount /esp

qemu-nbd -d /dev/nbd0


set -e

qemu-nbd -c /dev/nbd0 /media/sf_works/test.vhd 

parted -s /dev/nbd0 \
    mklabel gpt unit s \
    mkpart primary fat32 34 32767 \
    set 1 msftres on \
    name 1 Reserved \
    mkpart primary fat32 32768 1081343 \
    set 2 boot on \
    set 2 esp on \
    name 2 ESP \
    mkpart primary ntfs 1081344 66617343 \
    set 3 msftdata on \
    name 3 AppSys \
    print

mkfs.ntfs -Q /dev/nbd0p3

mkfs.vfat /dev/nbd0p2

mount /dev/nbd0p2 /esp

tar -C /esp -xvf /media/sf_works/EFI.tar

echo "extracth done" 

ls /esp


wimapply /media/sf_works/pxe/root/sources/boot.wim 1 /dev/nbd0p3


# 32=part 54=disk
diskUUID=$(sgdisk -p /dev/nbd0 | grep "(GUID):" ) 
diskUUID=${diskUUID#*:}
diskUUID=${diskUUID//-}
diskUUID=$(./encode-uuid.sh $diskUUID)

partUUID=$(sgdisk -i 3 /dev/nbd0 | grep "GUID:")
partUUID=${partUUID#*:}
partUUID=${partUUID//-}
partUUID=$(./encode-uuid.sh $partUUID)
echo $diskUUID
echo $partUUID

mount.winregfs /esp/EFI/Microsoft/Boot/BCD /reg
for i in $(find /reg -print | grep 1000001/Element.bin); do
  echo $i
  orig=$(xxd -p -c 100 $i)
  echo $orig 
  echo ${orig:0:32*2}$partUUID${orig:48*2:8*2}$diskUUID${orig:72*2} | xxd -r -p > $i
done
umount /reg
umount /esp
qemu-nbd -d /dev/nbd0
