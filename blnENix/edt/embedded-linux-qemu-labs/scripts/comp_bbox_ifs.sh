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

patch -p1 < "${BBOX_SRC_BCKP_PATH}/config_ifs.patch"

#if [[ "${#}" -eq 0 ]]; then
#  patch -p1 < "${BBOX_SRC_BCKP_PATH}/config_ifs_shared.patch"
#else
#  patch -p1 < "${BBOX_SRC_BCKP_PATH}/config_ifs.patch"
#fi

make -j4

IFS_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/tinysystem/ifsroot"
rm -r "${IFS_BASE_PATH:?}/bin"
rm -r "${IFS_BASE_PATH:?}/dev"
rm -r "${IFS_BASE_PATH:?}/etc"
rm -r "${IFS_BASE_PATH:?}/proc"
rm -r "${IFS_BASE_PATH:?}/sbin"
rm -r "${IFS_BASE_PATH:?}/sys"
rm -r "${IFS_BASE_PATH:?}/usr"

mkdir "${IFS_BASE_PATH:?}/dev"
for n in "2" "3" "4"; do
  sudo mknod "${IFS_BASE_PATH:?}/dev/tty${n}" c 4 "${n}"
  sudo chown "$(id -u)":"$(id -g)" "${IFS_BASE_PATH:?}/dev/tty${n}"
done

sudo mknod "${IFS_BASE_PATH:?}/dev/null" c 1 3
sudo chown "$(id -u)":"$(id -g)" "${IFS_BASE_PATH:?}/dev/null"

sudo mknod "${IFS_BASE_PATH:?}/dev/ttyAMA0" c 204 64
sudo chown "$(id -u)":"$(id -g)" "${IFS_BASE_PATH:?}/dev/ttyAMA0"

BBOX_ETC_BCKP_ARCHIVE="${BBOX_SRC_BCKP_PATH}/etc_ifs"
cp -r "${BBOX_ETC_BCKP_ARCHIVE}" "${IFS_BASE_PATH:?}"
mv "${IFS_BASE_PATH:?}/etc_ifs" "${IFS_BASE_PATH:?}/etc"

make install

ln -s "${IFS_BASE_PATH:?}/sbin/init" "${IFS_BASE_PATH:?}/init"
