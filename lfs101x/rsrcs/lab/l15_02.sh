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
lab(){
  echo "enter a name"
  read dir_name
  mkdir "${dir_name}"
  cd ./"${dir_name}" || exit 1;
  pwd
  for n in 1 2 3 4; do
    cur_file="${dir_name}${n}"
    touch "${cur_file}"
  done
  ls -l
  for cur_file in ${dir_name}?; do
    echo "this is file ${cur_file}"
  done
  ls -l ${dir_name}?
  cat ${dir_name}?
  echo "Goodbye"
}

setup
lab
cleanup
