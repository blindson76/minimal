#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d chntpw-*)
if [ -f Makefile ] ; then
  echo "Preparing $BUNDLE_NAME work area. This may take a while."
  make -j $NUM_JOBS clean
else
  echo "The clean phase for $BUNDLE_NAME has been skipped."
fi
rm -rf $DEST_DIR
echo "Configuring $BUNDLE_NAME."

GLIBC_INSTALLED=$WORK_DIR/glibc/glibc_installed
echo "Building $BUNDLE_NAME."
LDFLAGS="-L$TMP_ROOTFS/lib -L$TMP_ROOTFS/usr/lib -L$GLIBC_INSTALLED/lib" \
  CFLAGS="-I$GLIBC_INSTALLED/include -I$TMP_ROOTFS/include -I$TMP_ROOTFS/usr/include" \
  PKG_CONFIG_SYSROOT_DIR=${TMP_ROOTFS} \
  PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
  PKG_CONFIG_ALLOW_SYSTEM_LIBS=1 \
  PKG_CONFIG_PATH=$TMP_ROOTFS/lib/pkgconfig:$TMP_ROOTFS/usr/lib/pkgconfig \
  PKG_CONFIG_LIBDIR=$TMP_ROOTFS/lib/pkgconfig:$TMP_ROOTFS/usr/lib/pkgconfig \
  make -j $NUM_JOBS CFLAGS="-I$GLIBC_INSTALLED/include -I$TMP_ROOTFS/include -I$TMP_ROOTFS/usr/include"


echo "Reducing '$BUNDLE_NAME' size."
reduce_size .

cp -r --remove-destination ./chntpw \
  $OVERLAY_ROOTFS/bin/chntpw

echo "Bundle $BUNDLE_NAME has been installed."

cd $SRC_DIR
