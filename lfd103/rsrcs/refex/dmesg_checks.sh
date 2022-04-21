#!/bin/bash
#
#SPDX-License-Identifier: GPL-2.0
# Copyright(c) Shuah Khan <skhan@linuxfoundation.org>
#
# License: GPLv2

if [ "${1}" == "" ]; then
   echo "${0} <old name -r>"
   exit 1
fi

dmesg_level_check(){
  local old_ver="${1}"
  local new_ver=${2}
  local level="${3}"
  local level_str="${4}"
  dmesg -t -l "${level}" > "${new_ver}.dmesg_${level}"
  {
    echo "dmesg ${level_str} regressions"
    echo "--------------------------"
    diff "${old_ver}.dmesg_${level}" "${new_ver}.dmesg_${level}"
    echo "--------------------------"
  } >> dmesg_checks_results
}

release="$(uname -r)"
{
  echo "Start dmesg regression check for ${release}"

  echo "--------------------------"
} >> dmesg_checks_results

dmesg_check "${1}" "${release}" "emerg" "emergency"
dmesg_check "${1}" "${release}" "crit" "critical"
dmesg_check "${1}" "${release}" "alert" "alert"
dmesg_check "${1}" "${release}" "err" "error"
dmesg_check "${1}" "${release}" "warn" "warn"

dmesg -t > "${release}.dmesg"
{
  echo "dmesg regressions"
  echo "--------------------------"
  diff "${1}.dmesg" "${release}.dmesg"
  echo "--------------------------"
} >> dmesg_checks_results

dmesg -t -k > "${release}.dmesg_kern"
{
  echo "dmesg_kern regressions"
  echo "--------------------------"
  diff "${1}.dmesg_kern" "${release}.dmesg_kern"
  echo "--------------------------"
} >> dmesg_checks_results

{
  echo "--------------------------"

  echo "End dmesg regression check for ${release}"
} >> dmesg_checks_results
