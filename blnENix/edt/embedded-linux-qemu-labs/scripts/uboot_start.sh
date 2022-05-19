#!/bin/bash

BOOT_LDR_BASE="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/bootloader"
BOOT_LDR_DATA="${BOOT_LDR_BASE}/data"
BOOT_LDR="${BOOT_LDR_BASE}/u-boot"

sudo qemu-system-arm -M vexpress-a9 -m 128M -nographic -kernel "${BOOT_LDR}/u-boot" -sd "${BOOT_LDR_DATA}/sd.img" -net tap,script="${BOOT_LDR_DATA}/qemu-myifup.sh" -net nic
