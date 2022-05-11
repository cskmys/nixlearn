#!/bin/bash

link="git://git.kernel.org/pub/scm/linux/kernel/git"

repo1_addr="${link}/torvalds/linux.git"
repo2_addr="${link}/stable/linux-stable.git"
repo3_addr="${link}/stable/linux-stable-rc.git"
repo4_addr="${link}/shuah/linux-kselftest.git"

cd "${HOME}" || exit 1
mkdir "src"
cd "src" || exit 1
for repo_addr in "${repo1_addr}" "${repo2_addr}" "${repo3_addr}" "${repo4_addr}"; do
  git clone "${repo_addr}"
done

find "." -maxdepth 1 -mindepth 1 -type "d" -exec bash -c '
  cur_name="$(basename ${1})"
  mkdir -p "../logs/${cur_name}"
' shell "{}" ";"

beep
