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
  cp "./l18_01.c" "/tmp"
  mk_tmp_dir
  mv "/tmp/l18_01.c" "${TMP_DIR_PATH}"
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
  mem_val="${1}"

  echo "is this a test?[*/N]"
  read -r opt
  case "${opt}" in
    "no" | "NO" | "No" | "nO" | "n" | "N") test=0;;
    *) test=1;;
  esac
  [[ "${test}" -eq 1 ]] || sudo /sbin/swapoff -a # turning off the swap

  { [[ "${test}" -eq 1 ]] && gcc -o "l18_01" -DTEST "./l18_01.c";} || { gcc -o "l18_01" "./l18_01.c";}
  ./l18_01 "${mem_val}"

  [[ "${test}" -eq 1 ]] || sudo /sbin/swapon -a # turning on the swap back

  dmesg | tail -n 50
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
