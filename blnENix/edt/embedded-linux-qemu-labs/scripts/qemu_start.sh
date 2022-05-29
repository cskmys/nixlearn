#!/bin/bash

sudo apt install qemu-user qemu-system-arm

CROSS_TOOL="x-tools/arm-training-linux-uclibcgnueabihf/bin/"
CROSS_TOOL_PATH="${HOME}/${CROSS_TOOL}"
if ! [[ "${PATH}" == *"${CROSS_TOOL}"* ]]; then
  PATH="${CROSS_TOOL_PATH}:${PATH}"
fi

arm-linux-gcc --version

PGM_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/toolchain/"

SYSROOT_LIB_PATH=$(dirname "$(find "${HOME}/x-tools/" -name "ld-uClibc.so.0")")
SYSROOT_PATH=$(dirname "${SYSROOT_LIB_PATH}")

echo "Shared Lib App"
arm-linux-gcc -o hello "${PGM_BASE_PATH}/hello.c"
du -h hello
sudo qemu-arm -L "${SYSROOT_PATH}" hello
rm hello
echo ""
echo "Static App"
arm-linux-gcc -static -o hello "${PGM_BASE_PATH}/hello.c"
du -h hello
sudo qemu-arm hello
rm hello
