#!/bin/bash

sudo apt install device-tree-compiler

CROSS_TOOL="x-tools/arm-training-linux-uclibcgnueabihf/bin/"
CROSS_TOOL_PATH="${HOME}/${CROSS_TOOL}"
if ! [[ "${PATH}" == *"${CROSS_TOOL}"* ]]; then
  PATH="${CROSS_TOOL_PATH}:${PATH}"
fi

export ARCH=arm
export CROSS_COMPILE=arm-linux-

UBOOT_SRC_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/bootloader"
UBOOT_SRC_PATH="${UBOOT_SRC_BASE_PATH}/u-boot-v2020.04"
UBOOT_SRC_BCKP_PATH="${UBOOT_SRC_BASE_PATH}/bckp"
UBOOT_SRC_DATA_PATH="${UBOOT_SRC_BASE_PATH}/data"

if ! [[ -e ${UBOOT_SRC_BCKP_PATH} ]]; then
  echo "backup is not present, hence no automation"
  exit 1
fi

rm -rf "${UBOOT_SRC_PATH}"

cd "${UBOOT_SRC_BCKP_PATH}" || exit 1
pwd

UBOOT_SRC_BCKP_ARCHIVE="${UBOOT_SRC_BCKP_PATH}/u-boot-v2020.04.tar.gz"

if ! [[ -e "${UBOOT_SRC_BCKP_ARCHIVE}" ]]; then
  wget https://source.denx.de/u-boot/u-boot/-/archive/v2020.04/u-boot-v2020.04.tar.gz
fi

cd "${UBOOT_SRC_BASE_PATH}" || exit 1
pwd

tar xf "${UBOOT_SRC_BCKP_ARCHIVE}"

cd "${UBOOT_SRC_PATH}" || exit 1
pwd

rm -rf .git*

patch -p1 < "${UBOOT_SRC_DATA_PATH}/vexpress_flags_reset.patch"

make vexpress_ca9x4_defconfig

patch -p1 < "${UBOOT_SRC_BCKP_PATH}/config.patch"

make -j4
