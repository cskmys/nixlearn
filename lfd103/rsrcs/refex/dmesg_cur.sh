#!/bin/bash

dmesg_lev(){
  local cur_ver="${1}"
  local level="${2}"
  dmesg -t -l "${level}" > "${cur_ver}.dmesg_${level}"
}

release="$(uname -r)"

dmesg_lev "${release}" "emerg"
dmesg_lev "${release}" "alert"
dmesg_lev "${release}" "crit"
dmesg_lev "${release}" "err"
dmesg_lev "${release}" "warn"

dmesg -t > "${release}.dmesg"
dmesg -t -k > "${release}.dmesg_kern"
