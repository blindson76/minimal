#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the util-linux source directory which ls finds, e.g. 'util-linux-2.34'.
cd $(ls -d util-linux-*)

if [ -f Makefile ] ; then
  echo "Preparing '$BUNDLE_NAME' work area. This may take a while."
  make -j $NUM_JOBS clean
else
  echo "The clean phase for '$BUNDLE_NAME' has been skipped."
fi

rm -rf $DEST_DIR
mkdir -p $DEST_DIR/usr/share/doc/util-linux
mkdir -p $DEST_DIR/bin

echo "Configuring '$BUNDLE_NAME'."

LDFLAGS="-L$TMP_ROOTFS/lib -L$TMP_ROOTFS/usr/lib" \
  CFLAGS="-I$TMP_ROOTFS/include -I$TMP_ROOTFS/usr/include" \
  PKG_CONFIG_SYSROOT_DIR=${TMP_ROOTFS} \
  PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
  PKG_CONFIG_ALLOW_SYSTEM_LIBS=1 \
  PKG_CONFIG_PATH=$TMP_ROOTFS/lib/pkgconfig:$TMP_ROOTFS/usr/lib/pkgconfig \
  PKG_CONFIG_LIBDIR=$TMP_ROOTFS/lib/pkgconfig:$TMP_ROOTFS/usr/lib/pkgconfig \
./configure \
  ADJTIME_PATH=/var/lib/hwclock/adjtime   \
  --prefix=$DEST_DIR \
  --disable-all-programs \
  --enable-libuuid

echo "Building '$BUNDLE_NAME'."
make -j $NUM_JOBS

echo "Installing '$BUNDLE_NAME'."
make -j $NUM_JOBS install

echo "Reducing '$BUNDLE_NAME' size."
reduce_size $DEST_DIR/bin

cp -r --remove-destination $DEST_DIR/* \
  $TMP_ROOTFS
cp -r --remove-destination $DEST_DIR/lib/libuuid* \
  $OVERLAY_ROOTFS/lib

echo "Bundle '$BUNDLE_NAME' has been installed."

cd $SRC_DIR

