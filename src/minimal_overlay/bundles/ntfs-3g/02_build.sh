#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d ntfs-3g-*)

#sed -i -E "s/(^@INSTALL_LIBRARY_TRUE@\s+)(\\$\\(MV\\).*)$/\1$\\(MKDIR_P\\) $\\(DESTDIR\\)\/$\\(rootlibdir\\); \\\\\n\1\2/" libntfs-3g/Makefile.in 

if [ -f Makefile ] ; then
  echo "Preparing $BUNDLE_NAME work area. This may take a while."
  make -j $NUM_JOBS clean
else
  echo "The clean phase for $BUNDLE_NAME has been skipped."
fi
rm -rf $DEST_DIR
./autogen.sh
echo "Configuring $BUNDLE_NAME."

LDFLAGS="-L$TMP_ROOTFS/lib -L$TMP_ROOTFS/usr/lib" \
  CFLAGS="-I$TMP_ROOTFS/include -I$TMP_ROOTFS/usr/include" \
  PKG_CONFIG_SYSROOT_DIR=${TMP_ROOTFS} \
  PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
  PKG_CONFIG_ALLOW_SYSTEM_LIBS=1 \
  PKG_CONFIG_PATH=$TMP_ROOTFS/lib/pkgconfig:$TMP_ROOTFS/usr/lib/pkgconfig \
  PKG_CONFIG_LIBDIR=$TMP_ROOTFS/lib/pkgconfig:$TMP_ROOTFS/usr/lib/pkgconfig \
  ./configure \
  --disable-ldconfig \
  --prefix=/usr \
  --with-sysroot=$SYSROOT 

echo "Building $BUNDLE_NAME."
make -j $NUM_JOBS

echo "Installing $BUNDLE_NAME."
make -j $NUM_JOBS install DESTDIR="$DEST_DIR"

echo "Reducing '$BUNDLE_NAME' size."
reduce_size $DEST_DIR/bin
reduce_size $DEST_DIR/lib

cp -r --remove-destination $DEST_DIR/* \
  $TMP_ROOTFS

cp -r --remove-destination $DEST_DIR/usr/lib/libntfs* \
  $OVERLAY_ROOTFS/lib
cp -r --remove-destination $DEST_DIR/usr/sbin/* \
  $OVERLAY_ROOTFS/bin 
cp -r --remove-destination $DEST_DIR/usr/bin/* \
  $OVERLAY_ROOTFS/bin 
cp -r --remove-destination $DEST_DIR/sbin/* \
  $OVERLAY_ROOTFS/bin 
cp -r --remove-destination $DEST_DIR/bin/* \
  $OVERLAY_ROOTFS/bin 
echo "Bundle $BUNDLE_NAME has been installed."

cd $SRC_DIR
