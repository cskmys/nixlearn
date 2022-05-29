#!/bin/bash

sudo apt install u-boot-tools

echo "currently this script is not working"; exit 1

BBOX_SRC_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/tinysystem"
INITRAMFS_PATH="${BBOX_SRC_BASE_PATH}/initramfs"
NFS_BASE_PATH="${BBOX_SRC_BASE_PATH}/nfsroot"
INITRAMFS_ARCHIVE="${INITRAMFS_PATH}/initramfs.cpio"
UBOOT_INITRAMFS_ARCHIVE="${INITRAMFS_PATH}/uInitramfs"

rm "${INITRAMFS_ARCHIVE}"
rm "${INITRAMFS_ARCHIVE}.gz"
rm "${UBOOT_INITRAMFS_ARCHIVE}"

cd "${NFS_BASE_PATH}" || exit 1
pwd
find . | cpio -H newc -o > "${INITRAMFS_ARCHIVE}"

cd "${INITRAMFS_PATH}" || exit 1
pwd
gzip "initramfs.cpio"

mkimage -n 'Ramdisk Image' -A "arm" -O "linux" -T "ramdisk" -C "gzip" -d "initramfs.cpio.gz" "uInitramfs"

TFTP_EXPORT_DIR="/srv/tftp/"
sudo cp "uInitramfs" "${TFTP_EXPORT_DIR}"
