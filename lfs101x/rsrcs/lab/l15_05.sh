#!/bin/bash
get_tmp_dir_name(){
  TMP_DIR_NAME=$(basename "$0" | awk -F"." '{print $1}')
  TMP_DIR_PATH="/tmp/${TMP_DIR_NAME}"
}
mk_tmp_dir(){
  mkdir "${TMP_DIR_PATH}"
  cd "${TMP_DIR_PATH}" || { echo "can't mk_tmp_dir"; exit 1;}
}
rm_tmp_dir(){
  cd /tmp || { echo "can't go to /tmp"; exit 1;}
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
  if [[ ${opt} == "n" ]]; then
    echo "not cleaning up"
    return 0
  fi
  cleanup
}

exit_func(){
  echo "You need to enter 1 or 2 or 3"
  exit 1
}
check_re(){
  re=$1
  var=$2
  if ! [[ $var =~ $re ]]; then
      return 1
  fi
  return 0
}
check_ip(){
  if [[ $# -ne 1 ]]; then return 1; fi
  re="^[1-3]$"
  check_re "${re}" "${1}"
  return $?
}

func1(){
  echo "hey from func1"
}
func2(){
  echo "nb 2 gang gang baby"
}
func3(){
  echo "its thareee son"
}

lab(){
  echo "enter 1 or 2 or 3"
  read nb
  check_ip "${nb}"
  if [[ ${?} -ne 0 ]]; then exit_func; fi
  func${nb}
}

setup
lab
cleanup
