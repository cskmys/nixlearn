#!/bin/bash

sudo apt install device-tree-compiler tftpd-hpa tftp-hpa

if ! [[ -e "/var/lib/tftpboot" ]]; then
  if ! [[ -e "/srv/tftp" ]]; then
    echo "no tftp directories are present, will not be possible to load kernel and other files to u-boot"
    exit 1
  fi
fi

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

sed -i -e s:"# CONFIG_CMD_BOOTD is not set":"CONFIG_CMD_BOOTD=y":g -e s:"# CONFIG_CMD_EDITENV is not set":"CONFIG_CMD_EDITENV=y":g "${UBOOT_SRC_PATH}/.config"

make -j4

SD_CARD="${UBOOT_SRC_DATA_PATH}/sd.img"

rm "${SD_CARD}"
dd if="/dev/zero" of="${SD_CARD}" bs=1M count=1024

sfdisk "${SD_CARD}" < "${UBOOT_SRC_BCKP_PATH}/sd.part"

FREE_LOOPBACK_DEV="$(losetup -f)"
sudo losetup -f --show --partscan "${SD_CARD}"
sudo mkfs.vfat -F 16 -n boot "${FREE_LOOPBACK_DEV}p1"

TMP_MNT_LOC="$(pwd)/tmp"
mkdir "${TMP_MNT_LOC}"
sudo mount "${FREE_LOOPBACK_DEV}p1" "${TMP_MNT_LOC}"
sudo cp "${UBOOT_SRC_BCKP_PATH}/uboot.env" "${TMP_MNT_LOC}/uboot.env"
sudo umount "${TMP_MNT_LOC}"

sudo losetup -d "${FREE_LOOPBACK_DEV}"

NW_SCRIPT="${UBOOT_SRC_DATA_PATH}/qemu-myifup.sh"
HOST_IP="192.168.0.1/24" # don't change this coz this is the value used on the target side
echo -e "#!/bin/sh\n\n/sbin/ip a add ${HOST_IP} dev \$1\n/sbin/ip link set \$1 up" > "${NW_SCRIPT}"

sudo chmod a+x "${NW_SCRIPT}"
