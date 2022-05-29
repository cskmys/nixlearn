#!/bin/bash

sudo apt install nfs-kernel-server

CROSS_TOOL="x-tools/arm-training-linux-uclibcgnueabihf/bin/"
CROSS_TOOL_PATH="${HOME}/${CROSS_TOOL}"
if ! [[ "${PATH}" == *"${CROSS_TOOL}"* ]]; then
  PATH="${CROSS_TOOL_PATH}:${PATH}"
fi

export ARCH=arm
export CROSS_COMPILE=arm-linux-

KERNEL_SRC_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/kernel"
KERNEL_SRC_PATH="${KERNEL_SRC_BASE_PATH}/linux-5.9.16"
KERNEL_SRC_BCKP_PATH="${KERNEL_SRC_BASE_PATH}/bckp"

if ! [[ -e ${KERNEL_SRC_BCKP_PATH} ]]; then
  echo "backup is not present, hence no automation"
  exit 1
fi

rm -rf "${KERNEL_SRC_PATH}"

cd "${KERNEL_SRC_BCKP_PATH}" || exit 1
pwd

KERNEL_SRC_BCKP_ARCHIVE="${KERNEL_SRC_BCKP_PATH}/linux-5.9.16.tar.xz"

if ! [[ -e "${KERNEL_SRC_BCKP_ARCHIVE}" ]]; then
  wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.9.16.tar.xz
fi

cd "${KERNEL_SRC_BASE_PATH}" || exit 1
pwd

tar xf "${KERNEL_SRC_BCKP_ARCHIVE}"

cd "${KERNEL_SRC_PATH}" || exit 1
pwd

patch -p1 < "${KERNEL_SRC_BCKP_PATH}/config.patch"

make -j4

TFTP_EXPORT_DIR="/srv/tftp/"
sudo cp "./arch/arm/boot/zImage" "${TFTP_EXPORT_DIR}"
sudo cp "./arch/arm/boot/dts/vexpress-v2p-ca9.dtb" "${TFTP_EXPORT_DIR}"

CLIENT_IP=192.168.0.100 # do not change coz target's environment variable is set to this
NFS_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/tinysystem/nfsroot"
NFS_EXP_LINE="${NFS_BASE_PATH} ${CLIENT_IP}(rw,no_root_squash,no_subtree_check)"
case $(grep -Fx "${NFS_EXP_LINE}" "/etc/exports" > "/dev/null"; echo $?) in
  0)
    echo "NFS path already set"
    ;;
  1)
    echo "${NFS_EXP_LINE}" | sudo tee "/etc/exports" > "/dev/null"
    sudo exportfs -r
    ;;
  *)
    echo "error while checking for NFS path"
    exit 1
    ;;
esac
