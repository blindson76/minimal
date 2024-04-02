#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d lvm2-*)

if [ -f Makefile ] ; then
  echo "Preparing $BUNDLE_NAME work area. This may take a while."
  make -j $NUM_JOBS clean
else
  echo "The clean phase for $BUNDLE_NAME has been skipped."
fi
rm -rf $DEST_DIR
echo "Configuring $BUNDLE_NAME."

LDFLAGS="-L$OVERLAY_ROOTFS/usr/lib" CFLAGS="-I$OVERLAY_ROOTFS/usr/include" ./configure \
  --prefix=/usr \
  --with-sysroot=$SYSROOT
  CFLAGS="$CFLAGS"

echo "Building $BUNDLE_NAME."
LDFLAGS="-L$OVERLAY_ROOTFS/usr/lib" CFLAGS="-I$OVERLAY_ROOTFS/usr/include" make -j $NUM_JOBS

echo "Installing $BUNDLE_NAME."
LDFLAGS="-L$OVERLAY_ROOTFS/usr/lib" CFLAGS="-I$OVERLAY_ROOTFS/usr/include" make -j $NUM_JOBS install DESTDIR="$DEST_DIR"

install_to_overlay

echo "Bundle $BUNDLE_NAME has been installed."

cd $SRC_DIR
