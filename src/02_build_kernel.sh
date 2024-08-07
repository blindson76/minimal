#!/bin/sh

set -e

# Load common properties and functions in the current script.
. ./common.sh

echo "*** BUILD KERNEL BEGIN ***"

# Change to the kernel source directory which ls finds, e.g. 'linux-4.4.6'.
cd `ls -d $WORK_DIR/kernel/linux-*`

# Cleans up the kernel sources, including configuration files.
echo "Preparing kernel work area."
make mrproper -j $NUM_JOBS

# Read the 'USE_PREDEFINED_KERNEL_CONFIG' property from '.config'
USE_PREDEFINED_KERNEL_CONFIG=`read_property USE_PREDEFINED_KERNEL_CONFIG`
BUILD_KERNEL_MODULES=`read_property BUILD_KERNEL_MODULES`

if [ "$USE_PREDEFINED_KERNEL_CONFIG" = "true" -a ! -f $SRC_DIR/minimal_config/kernel.config ] ; then
  echo "Config file '$SRC_DIR/minimal_config/kernel.config' does not exist."
  USE_PREDEFINED_KERNEL_CONFIG=false
fi

if [ "$USE_PREDEFINED_KERNEL_CONFIG" = "true" ] ; then
  # Use predefined configuration file for the kernel.
  echo "Using config file '$SRC_DIR/minimal_config/kernel.config'."
  cp -f $SRC_DIR/minimal_config/kernel.config .config
else
  # Create default configuration file for the kernel.
  make defconfig -j $NUM_JOBS
  echo "Generated default kernel configuration."

# Enable fuse
  sed -i "s/.*CONFIG_FUSE_FS*/CONFIG_FUSE_FS=y/" .config
  echo "CONFIG_CUSE=y" >> .config
  echo "CONFIG_VIRTIO_FS=y" >> .config

  # Changes the name of the system to 'minimal'.
  sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"hloader\"/" .config

  # OVERLAYFS - BEGIN - most features are disabled (you don't really need them)

  # Enable overlay support, e.g. merge ro and rw directories (3.18+).
  sed -i "s/.*CONFIG_OVERLAY_FS.*/CONFIG_OVERLAY_FS=y/" .config

  # Turn on redirect dir feature by default (4.10+).
  echo "# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set" >> .config

  # Turn on inodes index feature by default (4.13+).
  echo "# CONFIG_OVERLAY_FS_INDEX is not set" >> .config

  # Follow redirects even if redirects are turned off (4.15+).
  echo "CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y" >> .config

  # Turn on NFS export feature by default (4.16+).
  echo "# CONFIG_OVERLAY_FS_NFS_EXPORT is not set" >> .config

  # Auto enable inode number mapping (4.17+).
  echo "# CONFIG_OVERLAY_FS_XINO_AUTO is not set" >> .config

  # Тurn on metadata only copy up feature by default (4.19+).
  echo "# CONFIG_OVERLAY_FS_METACOPY is not set" >> .config

  # OVERLAYFS - END

  # Тurn on metadata only copy up feature by default (4.19+).
  echo "CONFIG_OVERLAY_FS_DEBUG=y" >> .config

  sed -i "s/.*CONFIG_NTFS_FS.*/CONFIG_NTFS_FS=y/" .config
  echo "CONFIG_NTFS_DEBUG=n" >> .config
  echo "CONFIG_NTFS_RW=y" >> .config
  sed -i "s/.*CONFIG_NTFS3_FS.*/CONFIG_NTFS3_FS=y/" .config
  echo "CONFIG_NTFS3_64BIT_CLUSTER=n" >> .config
  echo "CONFIG_NTFS3_LZX_XPRESS=y" >> .config
  echo "CONFIG_NTFS3_FS_POSIX_ACL=n" >> .config

  sed -i "s/.*CONFIG_FB.*/CONFIG_FB=y/" .config
  echo "CONFIG_FB_EFI=n" >> .config
  echo "CONFIG_FB_VESA=y" >> .config
  # Required settings when using FB
  echo "CONFIG_FRAMEBUFFER_CONSOLE=y" >> .config
  echo "CONFIG_FRAMEBUFFER_CONSOLE_LEGACY_ACCELERATION=y" >> .config
  echo "CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y" >> .config
  echo "CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=n" >> .config
  echo "CONFIG_FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER=n" >> .config
  echo "CONFIG_LOGO=n" >> .config
  echo "CONFIG_FONTS=n" >> .config  
  echo "CONFIG_DRM_FBDEV_EMULATION=y" >> .config
  echo "CONFIG_DRM_FBDEV_OVERALLOC=100" >> .config
  echo "CONFIG_FIRMWARE_EDID=n" >> .config
  echo "CONFIG_FB_FOREIGN_ENDIAN=n" >> .config
  echo "CONFIG_FB_MODE_HELPERS=n" >> .config
  echo "CONFIG_FB_TILEBLITTING=n" >> .config
  echo "CONFIG_FB_CIRRUS=n" >> .config
  echo "CONFIG_FB_PM2=n" >> .config
  echo "CONFIG_FB_CYBER2000=n" >> .config
  echo "CONFIG_FB_ARC=n" >> .config
  echo "CONFIG_FB_ASILIANT=n" >> .config
  echo "CONFIG_FB_IMSTT=n" >> .config
  echo "CONFIG_FB_VGA16=y" >> .config
  echo "CONFIG_FB_UVESA=y" >> .config
  echo "CONFIG_FB_N411=n" >> .config
  echo "CONFIG_FB_HGA=n" >> .config
  echo "CONFIG_FB_OPENCORES=n" >> .config
  echo "CONFIG_FB_S1D13XXX=n" >> .config
  echo "CONFIG_FB_NVIDIA=n" >> .config
  echo "CONFIG_FB_RIVA=n" >> .config
  echo "CONFIG_FB_I740=n" >> .config
  echo "CONFIG_FB_LE80578=n" >> .config
  echo "CONFIG_FB_MATROX=n" >> .config
  echo "CONFIG_FB_RADEON=n" >> .config
  echo "CONFIG_FB_ATY128=n" >> .config
  echo "CONFIG_FB_ATY=n" >> .config
  echo "CONFIG_FB_S3=n" >> .config
  echo "CONFIG_FB_SAVAGE=n" >> .config
  echo "CONFIG_FB_SIS=n" >> .config
  echo "CONFIG_FB_NEOMAGIC=n" >> .config
  echo "CONFIG_FB_KYRO=n" >> .config
  echo "CONFIG_FB_3DFX=n" >> .config
  echo "CONFIG_FB_VOODOO1=n" >> .config
  echo "CONFIG_FB_VT8623=n" >> .config
  echo "CONFIG_FB_TRIDENT=n" >> .config
  echo "CONFIG_FB_ARK=n" >> .config
  echo "CONFIG_FB_PM3=n" >> .config
  echo "CONFIG_FB_CARMINE=n" >> .config
  echo "CONFIG_FB_SMSCUFX=n" >> .config
  echo "CONFIG_FB_UDL=n" >> .config
  echo "CONFIG_FB_IBM_GXT4500=n" >> .config
  echo "CONFIG_FB_VIRTUAL=n" >> .config
  echo "CONFIG_FB_METRONOME=n" >> .config
  echo "CONFIG_FB_MB862XX=n" >> .config
  echo "CONFIG_FB_SIMPLE=y" >> .config
  echo "CONFIG_FB_SM712=n" >> .config
  echo "CONFIG_FB_DEVICE=y" >> .config

  echo "CONFIG_CIFS=m" >> .config
  echo "CONFIG_CIFS_STATS2=y" >> .config
  echo "CONFIG_CIFS_ALLOW_INSECURE_LEGACY=y" >> .config
  echo "CONFIG_CIFS_UPCALL=y" >> .config
  echo "CONFIG_CIFS_XATTR=y" >> .config
  echo "CONFIG_CIFS_POSIX=y" >> .config
  echo "CONFIG_CIFS_DEBUG=y" >> .config
  echo "CONFIG_CIFS_DEBUG2=y" >> .config
  echo "CONFIG_CIFS_DEBUG_DUMP_KEYS=y" >> .config
  echo "CONFIG_CIFS_DFS_UPCALL=y" >> .config
  echo "CONFIG_CIFS_SWN_UPCALL=y" >> .config
  echo "CONFIG_CIFS_ROOT=y" >> .config

  echo "CONFIG_NFS_V4_1=y" >> .config
  echo "CONFIG_NFS_V4_2=y" >> .config
  echo "CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN=\"bootserver\"" >> .config
  echo "CONFIG_NFS_V4_1_MIGRATION=y" >> .config
  echo "CONFIG_NFS_V4_2_READ_PLUS=y" >> .config

  
  echo "CONFIG_INPUT_MOUSEDEV=y" >> .config
  echo "CONFIG_INPUT_MOUSEDEV_PSAUX=n" >> .config
  echo "CONFIG_INPUT_MOUSEDEV_SCREEN_X=1920" >> .config
  echo "CONFIG_INPUT_MOUSEDEV_SCREEN_Y=1200" >> .config
  
  echo "CONFIG_DRM_SIMPLEDRM=y" >> .config


  #sed -i "s/.*CONFIG_EFIVAR_FS.*/CONFIG_EFIVAR_FS=y/" .config   


  

  # Step 1 - disable all active kernel compression options (should be only one).
  sed -i "s/.*\\(CONFIG_KERNEL_.*\\)=y/\\#\\ \\1 is not set/" .config

  # Step 2 - enable the 'xz' compression option.
  sed -i "s/.*CONFIG_KERNEL_XZ.*/CONFIG_KERNEL_XZ=y/" .config

  # Enable the VESA framebuffer for graphics support.
  sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config

  # Read the 'USE_BOOT_LOGO' property from '.config'
  USE_BOOT_LOGO=`read_property USE_BOOT_LOGO`

  if [ "$USE_BOOT_LOGO" = "true" ] ; then
    sed -i "s/.*CONFIG_LOGO_LINUX_CLUT224.*/CONFIG_LOGO_LINUX_CLUT224=y/" .config
    echo "Boot logo is enabled."
  else
    sed -i "s/.*CONFIG_LOGO_LINUX_CLUT224.*/\\# CONFIG_LOGO_LINUX_CLUT224 is not set/" .config
    echo "Boot logo is disabled."
  fi

  # Disable debug symbols in kernel => smaller kernel binary.
  sed -i "s/^CONFIG_DEBUG_KERNEL.*/\\# CONFIG_DEBUG_KERNEL is not set/" .config

  # Enable the EFI stub
  sed -i "s/.*CONFIG_EFI_STUB.*/CONFIG_EFI_STUB=y/" .config

  # Request that the firmware clear the contents of RAM after reboot (4.14+).
  echo "CONFIG_RESET_ATTACK_MITIGATION=y" >> .config

  # Disable Apple Properties (Useful for Macs but useless in general)
  echo "CONFIG_APPLE_PROPERTIES=n" >> .config

  # Check if we are building 64-bit kernel.
  if [ "`grep "CONFIG_X86_64=y" .config`" = "CONFIG_X86_64=y" ] ; then
    # Enable the mixed EFI mode when building 64-bit kernel.
    echo "CONFIG_EFI_MIXED=y" >> .config
  fi
fi

# Compile the kernel with optimization for 'parallel jobs' = 'number of processors'.
# Good explanation of the different kernels:
# http://unix.stackexchange.com/questions/5518/what-is-the-difference-between-the-following-kernel-makefile-terms-vmlinux-vmlinux
echo "Building kernel."
make \
  CFLAGS="$CFLAGS" \
  bzImage -j $NUM_JOBS

if [ "$BUILD_KERNEL_MODULES" = "true" ] ; then
  echo "Building kernel modules."
  make \
    CFLAGS="$CFLAGS" \
    modules -j $NUM_JOBS
fi

# Prepare the kernel install area.
echo "Removing old kernel artifacts. This may take a while."
rm -rf $KERNEL_INSTALLED
mkdir $KERNEL_INSTALLED

echo "Installing the kernel."
# Install the kernel file.
cp arch/x86/boot/bzImage \
  $KERNEL_INSTALLED/kernel

if [ "$BUILD_KERNEL_MODULES" = "true" ] ; then
  make INSTALL_MOD_PATH=$KERNEL_INSTALLED \
    modules_install -j $NUM_JOBS
fi

# Install kernel headers which are used later when we build and configure the
# GNU C library (glibc).
echo "Generating kernel headers."
make \
  INSTALL_HDR_PATH=$KERNEL_INSTALLED \
  headers_install -j $NUM_JOBS

cd $SRC_DIR

echo "*** BUILD KERNEL END ***"
