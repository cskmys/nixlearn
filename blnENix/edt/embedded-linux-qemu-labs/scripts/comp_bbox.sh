#!/bin/bash

CROSS_TOOL="x-tools/arm-training-linux-uclibcgnueabihf/bin/"
CROSS_TOOL_PATH="${HOME}/${CROSS_TOOL}"
if ! [[ "${PATH}" == *"${CROSS_TOOL}"* ]]; then
  PATH="${CROSS_TOOL_PATH}:${PATH}"
fi

export ARCH=arm
export CROSS_COMPILE=arm-linux-

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
rm -r "${NFS_BASE_PATH:?}/etc"
rm -r "${NFS_BASE_PATH:?}/proc"
rm -r "${NFS_BASE_PATH:?}/sys"

mkdir "${NFS_BASE_PATH:?}/dev"
for n in "2" "3" "4"; do
  sudo mknod "${NFS_BASE_PATH:?}/dev/tty${n}" c 4 "${n}"
  sudo chown "$(id -u)":"$(id -g)" "${NFS_BASE_PATH:?}/dev/tty${n}"
done

sudo mknod "${NFS_BASE_PATH:?}/dev/null" c 1 3
sudo chown "$(id -u)":"$(id -g)" "${NFS_BASE_PATH:?}/dev/null"

sudo mknod "${NFS_BASE_PATH:?}/dev/ttyAMA0" c 204 64
sudo chown "$(id -u)":"$(id -g)" "${NFS_BASE_PATH:?}/dev/ttyAMA0"

BBOX_ETC_BCKP_ARCHIVE="${BBOX_SRC_BCKP_PATH}/etc"
cp -r "${BBOX_ETC_BCKP_ARCHIVE}" "${NFS_BASE_PATH:?}"

make install
