# Utilities


Different kind of small utility items will be tracked under this repository.

## Getting Started

Each item may require specific actions. So check corresponding items.

## Content

* [**Bitbucket HAVELSAN ReadMe.md Template**](KKST-Ank-Konf-Tk@havelsan.com.tr) - You can use this template for your git repositories.

## Build Linux v6.8 x86_64

Run `bash scripts/build-kernel.sh` to download Linux v6.8 into `src/`, apply
the EFI chainload patch, enable `CONFIG_EFI_STUB_CHAINLOAD`, and build the
x86_64 `bzImage`. The chainload configuration defaults to
`/EFI/BOOT/boot.conf` on the EFI system partition; its first line should be
the EFI path of the executable to start.

Set `KERNEL_SRC` to use an existing kernel source directory and `JOBS` to
override the parallel build job count.
