#!/bin/bash

sudo apt install build-essential git autoconf bison flex texinfo help2man gawk libtool-bin libncurses5-dev unzip

TOOLCHAIN_BASE="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/toolchain/"
TOOLCHAIN_SRC_BCKP_PATH="${TOOLCHAIN_BASE}/bckp"
TOOLCHAIN_SRC_PATH="${TOOLCHAIN_BASE}/crosstool-ng"

if ! [[ -e ${TOOLCHAIN_SRC_BCKP_PATH} ]]; then
  echo "backup is not present, hence no automation"
  exit 1
fi

rm -rf "${TOOLCHAIN_SRC_PATH}"

cd "${TOOLCHAIN_BASE}" || exit 1

git clone https://github.com/crosstool-ng/crosstool-ng.git

cd "${TOOLCHAIN_SRC_PATH}" || exit 1

git checkout 25f6dae8

rm -rf .git*

./bootstrap

./configure --enable-local

make -j4

./ct-ng help

./ct-ng arm-cortexa9_neon-linux-gnueabihf

patch -p1 < "${TOOLCHAIN_SRC_BCKP_PATH}/config.patch"

TOOLCHAIN_INSTALLATION_PATH="/home/csk/x-tools/"
rm -rf "${TOOLCHAIN_INSTALLATION_PATH}"

./ct-ng build

./ct-ng clean

./ct-ng distclean
