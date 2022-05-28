#!/bin/bash

CROSS_TOOL="x-tools/arm-training-linux-uclibcgnueabihf/bin/"
CROSS_TOOL_PATH="${HOME}/${CROSS_TOOL}"
if ! [[ "${PATH}" == *"${CROSS_TOOL}"* ]]; then
  PATH="${CROSS_TOOL_PATH}:${PATH}"
fi

PGM_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/tinysystem/data"
arm-linux-gcc -o hello "${PGM_BASE_PATH}/hello.c"

NFS_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/tinysystem/nfsroot"
NFS_HOME="${NFS_BASE_PATH:?}/home"
NFS_LIB="${NFS_BASE_PATH:?}/lib"
rm -rf "${NFS_HOME}"

mkdir "${NFS_HOME}"
mkdir -p "${NFS_LIB}"

mv hello "${NFS_HOME}"

for lib_file in "ld-uClibc.so.0" "libc.so.0"; do
  rm -f "${NFS_LIB}/${lib_file}"
  cp "$(find "${HOME}/x-tools/" -name "${lib_file}")" "${NFS_LIB}"
done
