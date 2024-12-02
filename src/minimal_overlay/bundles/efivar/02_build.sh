#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d efivar-*)
if [ -f Makefile ] ; then
  echo "Preparing $BUNDLE_NAME work area. This may take a while."
  make -j $NUM_JOBS clean
else
  echo "The clean phase for $BUNDLE_NAME has been skipped."
fi
rm -rf $DEST_DIR


echo "Building $BUNDLE_NAME."
make -j $NUM_JOBS efivar

echo "Installing $BUNDLE_NAME."
make -j $NUM_JOBS install DESTDIR="$DEST_DIR"

echo "Reducing '$BUNDLE_NAME' size."
reduce_size $DEST_DIR/usr/bin
reduce_size $DEST_DIR/usr/lib

cp -r --remove-destination $DEST_DIR/* \
  $TMP_ROOTFS


echo "Bundle $BUNDLE_NAME has been installed."

cd $SRC_DIR
