#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d parted-*)
sed -i -e'/gets is a security/d' lib/stdio.in.h
#sed -i -e's/_IO_ftrylockfile/_IO_EOF_SEEN/' lib/fseeko.c
if [ -f Makefile ] ; then
  echo "Preparing $BUNDLE_NAME work area. This may take a while."
  make -j $NUM_JOBS clean
else
  echo "The clean phase for $BUNDLE_NAME has been skipped."
fi

rm -rf $DEST_DIR
echo "Configuring $BUNDLE_NAME."
LDFLAGS="-L$OVERLAY_ROOTFS/usr/lib -L$GLIBC_INSTALLED/lib" CFLAGS="-fPIC -I$OVERLAY_ROOTFS/usr/include -I$GLIBC_INSTALLED/include" ./configure \
  --prefix=/usr \
  --with-sysroot=$SYSROOT
  CFLAGS="$CFLAGS"

echo "Building $BUNDLE_NAME."
CFLAGS="-fPIC" make -j $NUM_JOBS

echo "Installing $BUNDLE_NAME."
make -j $NUM_JOBS install DESTDIR="$DEST_DIR"

install_to_overlay

echo "Bundle $BUNDLE_NAME has been installed."

cd $SRC_DIR
