#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d efibootmgr-*)

if [ -f Makefile ] ; then
  echo "Preparing $BUNDLE_NAME work area. This may take a while."
  make EFIDIR=LFS -j $NUM_JOBS clean
else
  echo "The clean phase for $BUNDLE_NAME has been skipped."
fi
rm -rf $DEST_DIR
echo "Configuring $BUNDLE_NAME."


echo "Building $BUNDLE_NAME."
  CFLAGS="-I${TMP_ROOTFS}/usr/include" \
  PKG_CONFIG_SYSROOT_DIR=${TMP_ROOTFS} \
  PKG_CONFIG_PATH=$TMP_ROOTFS/usr/lib64/pkgconfig/ \
  make EFIDIR=LFS -j $NUM_JOBS
  
echo "Installing $BUNDLE_NAME."
make EFIDIR=LFS -j $NUM_JOBS install DESTDIR="$DEST_DIR"

echo "Reducing '$BUNDLE_NAME' size."
reduce_size $DEST_DIR/usr/sbin


cp -r --remove-destination $DEST_DIR/usr/sbin/* \
  $OVERLAY_ROOTFS/sbin

echo "copying dependencies"
cp -r --remove-destination $TMP_ROOTFS/usr/lib64/libefi* \
  $OVERLAY_ROOTFS/lib


echo "Bundle $BUNDLE_NAME has been installed."

cd $SRC_DIR
