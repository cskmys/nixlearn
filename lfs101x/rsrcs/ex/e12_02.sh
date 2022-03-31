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
# Try-It-Yourself: Using File Permission
  mkdir Desktop Documents Downloads Music Pictures Public Templates Videos
  touch script1.sh sample2.sh
# Tasks to be performed:
# View the files present in the current directory in the long listing format.
  ls -l
# By default the permissions for a file will be rw-rw-r--, change the permissions of the sample2.sh file to rwxr--r-x, using the rwx notation.
  chmod uo+x,g-w sample2.sh
# View the files present in the current directory in the long listing format.
  ls -l
# By default the permissions for a file will be rw-rw-r--, change the permissions of the script1.sh file to rwxr-x--x, using 421 method.
  chmod 751 script1.sh
# View the files present in the current directory in the long listing format.
  ls -l
}

setup
lab
cleanup
