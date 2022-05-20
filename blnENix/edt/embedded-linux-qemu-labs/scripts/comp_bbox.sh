#!/bin/bash

CROSS_TOOL="x-tools/arm-training-linux-uclibcgnueabihf/bin/"
CROSS_TOOL_PATH="${HOME}/${CROSS_TOOL}"
if ! [[ "${PATH}" == *"${CROSS_TOOL}"* ]]; then
  PATH="${CROSS_TOOL_PATH}:${PATH}"
fi

BBOX_SRC_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/tinysystem/"
BBOX_SRC_PATH="${BBOX_SRC_BASE_PATH}/busybox-1.35.0"
BBOX_SRC_BCKP_PATH="${BBOX_SRC_BASE_PATH}/bckp"

if ! [[ -e ${BBOX_SRC_BCKP_PATH} ]]; then
  echo "backup is not present, hence no automation"
  exit 1
fi

rm -rf "${BBOX_SRC_PATH}"

cd "${BBOX_SRC_BCKP_PATH}" || exit 1
pwd

BBOX_SRC_BCKP_ARCHIVE="${BBOX_SRC_BCKP_PATH}/busybox-1.35.0.tar.bz2"

if ! [[ -e "${BBOX_SRC_BCKP_ARCHIVE}" ]]; then
  wget https://busybox.net/downloads/busybox-1.35.0.tar.bz2
fi

cd "${BBOX_SRC_BASE_PATH}" || exit 1
pwd

tar xf "${BBOX_SRC_BCKP_ARCHIVE}"

cd "${BBOX_SRC_PATH}" || exit 1
pwd

patch -p1 < "${BBOX_SRC_BCKP_PATH}/config.patch"

make -j4

NFS_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/tinysystem/nfsroot"
rm -r "${NFS_BASE_PATH:?}/bin"
rm -r "${NFS_BASE_PATH:?}/sbin"
rm -r "${NFS_BASE_PATH:?}/usr"
rm -r "${NFS_BASE_PATH:?}/dev"

mkdir "${NFS_BASE_PATH:?}/dev"

make install
