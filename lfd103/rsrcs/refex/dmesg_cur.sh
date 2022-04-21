#!/bin/bash

check_empty(){
  local file_name="${1}"
  if ! [[ -s "${file_name}" ]]; then
    echo "${file_name} has some msgs"
  fi
}

dmesg_lev(){
  local cur_ver="${1}"
  local level="${2}"
  dmesg -t -l "${level}" > "${cur_ver}.dmesg_${level}"
  check_empty "${cur_ver}.dmesg_${level}"
}

release="$(uname -r)"

dmesg_lev "${release}" "emerg"
dmesg_lev "${release}" "alert"
dmesg_lev "${release}" "crit"
dmesg_lev "${release}" "err"
dmesg_lev "${release}" "warn"

dmesg -t > "${release}.dmesg"
check_empty "${release}.dmesg"

dmesg -t -k > "${release}.dmesg_kern"
check_empty "${release}.dmesg_kern"
