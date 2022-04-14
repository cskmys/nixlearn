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
  echo "all files in /tmp newer than ${TMP_DIR_PATH}:"
  find "/tmp" -newer "${TMP_DIR_PATH}" 2> "/dev/null" # you shouldn't see any output here
  echo ""
  echo "5 files in /etc that end with .conf:"
  find "/etc" -name "*.conf" 2> "/dev/null" | head -5
  echo ""
  echo "5 dirs in /etc :"
  find "/etc" -type "d" 2> "/dev/null" | head -5
  echo ""
  echo "5 backup files in system in long listing format:"
  find "/" -name "*.bak" 2> "/dev/null" -exec ls -l {} ';' | head -5
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
