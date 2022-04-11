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

  [[ "${#}" -ne "1" ]] && echo "give a month number" && exit_func "1"

  month="${1}"

  case "${month}" in
    "01" | "1") echo "Jan";;
    "02" | "2") echo "Fev";;
    "03" | "3") echo "Mar";;
    "04" | "4") echo "Avr";;
    "05" | "5") echo "Mai";;
    "06" | "6") echo "Jui";;
    "07" | "7") echo "Jul";;
    "08" | "8") echo "Aou";;
    "09" | "9") echo "Sep";;
    "10") echo "Oct";;
    "11") echo "Nov";;
    "12") echo "Dec";;
    *) echo "Invalid number";
       echo "Number should be between 1-12";;
  esac
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
