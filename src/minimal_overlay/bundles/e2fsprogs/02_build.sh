#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d e2fsprogs-*)

if [ -f Makefile ] ; then
  echo "Preparing $BUNDLE_NAME work area. This may take a while."
  make -j $NUM_JOBS clean
else
  echo "The clean phase for $BUNDLE_NAME has been skipped."
fi

rm -rf $DEST_DIR
echo "Configuring $BUNDLE_NAME."
./configure \
  --prefix=/usr \
  --with-sysroot=$SYSROOT
  CFLAGS="$CFLAGS"

echo "Building $BUNDLE_NAME."
make -j $NUM_JOBS

echo "Installing $BUNDLE_NAME."
make -j $NUM_JOBS install DESTDIR="$DEST_DIR"


echo "Installing $BUNDLE_NAME."
make -j $NUM_JOBS install-libs DESTDIR="$DEST_DIR"

install_to_overlay

echo "Bundle $BUNDLE_NAME has been installed."

cd $SRC_DIR
