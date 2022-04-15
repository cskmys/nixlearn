#!/bin/bash
mk_tmp_dir(){
  TMP_DIR_NAME=$(basename "${0}" | awk -F"." '{print $1}')
  TMP_DIR_PATH=$(mktemp -d "/tmp/${TMP_DIR_NAME}.XXX")
  cd "${TMP_DIR_PATH}" || { echo "can't mk_tmp_dir"; exit 1;}
}
rm_tmp_dir(){
  cd "/tmp" || { echo "can't go to /tmp"; exit 1;}
  sudo rm -r "${TMP_DIR_PATH}"
}
setup(){
  cp "./l06_03.c" "/tmp"
  mk_tmp_dir
  mv "/tmp/l06_03.c" "${TMP_DIR_PATH}"
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
  su_file="s_file"
  usr_file="u_file"

  sudo touch "${su_file}"
  touch "${usr_file}"

  gcc -o "l06_03" "./l06_03.c"

  echo "file info"
  ls -l "./l06_03"
  ls -l "${su_file}"
  ls -l "${usr_file}"

  echo "without sudo"
  ./l06_03 "${su_file}"
  ./l06_03 "${usr_file}"

  echo "with sudo"
  sudo ./l06_03 "${su_file}"
  sudo ./l06_03 "${usr_file}"
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
