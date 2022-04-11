#!/bin/bash
get_tmp_dir_name(){
  TMP_DIR_NAME=$(basename "${0}" | awk -F"." '{print $1}')
  TMP_DIR_PATH="/tmp/${TMP_DIR_NAME}"
}
mk_tmp_dir(){
  mkdir "${TMP_DIR_PATH}"
  cd "${TMP_DIR_PATH}" || { echo "can't mk_tmp_dir"; exit 1;}
}
rm_tmp_dir(){
  cd "/tmp" || { echo "can't go to /tmp"; exit 1;}
  rm -r "${TMP_DIR_PATH}"
}
setup(){
  get_tmp_dir_name
  rm_tmp_dir
  mk_tmp_dir
}
cleanup(){
  rm_tmp_dir
}
cleanup_w_permission(){
  echo "You want to cleanup[*/n]?"
  read -r opt
  if [[ "${opt}" == "n" ]]; then
    echo "not cleaning up"
    return 0
  fi
  cleanup
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
  str1="${1}"
  str2="${2}"

  [[ -z "${str1}" ]] && echo "empty string"

  [[ -n "${str1}" ]] && echo "non empty string"

  [[ "${#}" -lt "2" ]] && echo "give 2 arguments" && exit_func "1"

  str1_len="${#str1}"
  str2_len="${#str2}"
  echo "argument one of length ${str1_len}"
  echo "argument two of length ${str2_len}"

  if [[ "${str1_len}" -eq "${str2_len}" ]]; then
    echo "argument one is same length as two"
  elif [[ "${str1_len}" -gt "${str2_len}" ]]; then
    echo "argument one is longer than two"
  else
    echo "argument one is shorter than two"
  fi

  if [[ "${str1}" == "${str2}" ]]; then
    echo "arguments are same"
  else
    echo "arguments are not same"
  fi
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
