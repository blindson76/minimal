#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
kernel_version="6.8"
kernel_src="${KERNEL_SRC:-${repo_root}/src}"
patch_file="${repo_root}/patches/0001-x86-64-efi-stub-config-chainload.patch"
archive_url="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${kernel_version}.tar.xz"

if [[ ! -f "${kernel_src}/Makefile" ]]; then
	mkdir -p "${kernel_src}"
	archive="$(mktemp "${TMPDIR:-/tmp}/linux-${kernel_version}.XXXXXX.tar.xz")"
	trap 'rm -f "${archive}"' EXIT
	curl --fail --location --retry 3 --output "${archive}" "${archive_url}"
	tar -xJf "${archive}" --strip-components=1 -C "${kernel_src}"
fi

if [[ ! -f "${kernel_src}/Makefile" ]]; then
	echo "Kernel source not found in ${kernel_src}" >&2
	exit 1
fi

version="$(sed -n 's/^VERSION = //p' "${kernel_src}/Makefile").$(sed -n 's/^PATCHLEVEL = //p' "${kernel_src}/Makefile").$(sed -n 's/^SUBLEVEL = //p' "${kernel_src}/Makefile")"
if [[ "${version}" != "6.8.0" ]]; then
	echo "Expected Linux 6.8.0 source in ${kernel_src}, found ${version}" >&2
	exit 1
fi

if grep -q '^config EFI_STUB_CHAINLOAD$' "${kernel_src}/drivers/firmware/efi/Kconfig" &&
	grep -q '^static efi_status_t efi_stub_chainload' \
		"${kernel_src}/drivers/firmware/efi/libstub/x86-stub.c"; then
	echo "EFI chainload patch is already applied"
elif git -C "${kernel_src}" apply --check "${patch_file}"; then
	git -C "${kernel_src}" apply "${patch_file}"
else
	echo "EFI chainload patch does not apply to ${kernel_src}" >&2
	exit 1
fi

if [[ ! -f "${kernel_src}/.config" ]]; then
	make -C "${kernel_src}" ARCH=x86 x86_64_defconfig
fi

"${kernel_src}/scripts/config" --file "${kernel_src}/.config" \
	--enable EFI \
	--enable EFI_STUB \
	--enable EFI_STUB_CHAINLOAD \
	--set-str EFI_STUB_CHAINLOAD_CONFIG "/EFI/BOOT/boot.conf"
make -C "${kernel_src}" ARCH=x86 olddefconfig

if ! grep -q '^CONFIG_EFI_STUB_CHAINLOAD=y$' "${kernel_src}/.config"; then
	echo "CONFIG_EFI_STUB_CHAINLOAD could not be enabled for this configuration" >&2
	exit 1
fi

jobs="${JOBS:-$(nproc)}"
make -C "${kernel_src}" ARCH=x86 -j"${jobs}" bzImage
