#!/bin/bash

su root
apt install sudo
username="csk"
if [[ "${#}" -eq 1 ]]; then
  username="${1}"
fi
echo "${username} ALL=(ALL) ALL" > "/etc/sudoers.d/${username}"
chmod 440 "/etc/sudoers.d/${username}"
exit
