#!/bin/bash
mk_tmp_dir(){
  TMP_DIR_NAME=$(basename "${0}" | awk -F"." '{print $1}')
  TMP_DIR_PATH=$(mktemp -d "/tmp/${TMP_DIR_NAME}.XXX")
  cd "${TMP_DIR_PATH}" || { echo "can't mk_tmp_dir"; exit 1;}
}
rm_tmp_dir(){
  cd "/tmp" || { echo "can't go to /tmp"; exit 1;}
  rm -r "${TMP_DIR_PATH}"
}
setup(){
  mk_tmp_dir
}
cleanup(){
  rm_tmp_dir
}
cleanup_w_permission(){
  echo "You want to cleanup[*/n]?"
  read -r opt
  case "${opt}" in
    "no" | "NO" | "No" | "nO" | "n" | "N") echo "not cleaning up";;
    *) cleanup;;
  esac
}
exit_func(){
  cleanup
  [[ -z "${1}" ]] && exit "0" || exit "${1}"
}
is_pgm_installed(){
  if which "${1}"; then
    return 0
  fi
  return 1
}
setup_pgm(){
  pgm="${1}"
  if [[ ((${#} -eq 1)) ]]; then
    pkg="${1}"
  elif [[ ((${#} -eq 2)) ]]; then
    pkg="${2}"
  else
    echo "provide just binary name if binary name and package name are same or both"
  fi

  if is_pgm_installed "${pgm}" "${pkg}"; then
    echo "${pgm} from ${pkg} is installed"
    return 0
  fi
  echo "${pkg} package needs to be installed for command ${pgm}"
  sudo apt -y install "${pkg}"
}
lab(){
  vol="./part"
  dd if="/dev/zero" of="${vol}" count=500 bs=1M # creating file for loopback filesystem
  mkfs -t "ext4" "${vol}" # formatting it as "ext4"

  mnt_pt="./mnt"
  mkdir "${mnt_pt}" # creating an empty directory for use as a mount point
  sudo mount "${vol}" "${mnt_pt}" # mounting
  df -Th | grep -e "${TMP_DIR_PATH}" # get mounted partition name and info

  sudo touch "${mnt_pt}/abc" # creating file in mounted filesystem
  ls -l "${mnt_pt}" # get filesystem contents

  sudo umount "${mnt_pt}" # unmounting loopback filesystem

  fsck.ext4 -f "${vol}" # check and correct filesystem for any errors
  dumpe2fs "${vol}" | grep -i -e "maximum mount count" # get max mount count of filesystem
  tune2fs -c 10 "${vol}" # change max mount count
  dumpe2fs "${vol}" | grep -i -e "maximum mount count" # verify max mount count of filesystem after change

  sudo mount "${vol}" "${mnt_pt}" # mount again
  df -Th | grep -e "${TMP_DIR_PATH}" # get mount info

  ls -l "${mnt_pt}" # get filesystem contents

  sudo umount "${mnt_pt}" # unmount again, so that this whole lab can be deleted and cleaned up
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
