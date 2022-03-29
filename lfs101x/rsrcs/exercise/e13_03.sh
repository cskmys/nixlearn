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
# Try-It-Yourself: Using head and tail
  echo -e "Rocky\nBullwinkle\nNatasha\nBoris\nSherman\nPeabody\nSherman\nBoris\nNatasha\nBullwinkle" > friends.txt
# Tasks to be performed:
# View the first five lines of a file named friends.txt using head.
  head -n 5 friends.txt
  echo " "
# View the last five lines of a file named friends.txt using tail.
  tail -5 friends.txt
}

setup
lab
cleanup
