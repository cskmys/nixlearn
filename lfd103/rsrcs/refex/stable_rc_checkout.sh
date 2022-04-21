#!/bin/bash
## SPDX-License-Identifier: GPL-2.0
# Copyright(c) Shuah Khan <skhan@linuxfoundation.org>
#
# License: GPLv2
# Example usage: stable_rc_checkout.sh <stable-rc e.g 5.2>
mkdir -p stable_rc
cd stable_rc || exit 1
git clone "git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-${1}.y"
cd "linux-${1}.y" || exit 1
cp /boot/config-5.4.0-109-generic .config || exit 1 # update script
make -j2 all
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
su -c "make modules_install install"
echo "Ready for reboot test of Linux-${1}"
