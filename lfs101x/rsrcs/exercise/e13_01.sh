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
# Try-It-Yourself: Using cat

# Tasks to be performed:
# Using cat, create a file named test1, type "Line1" and save it by pressing Ctrl-D.
# Using cat, create a file named test2, type "Line2" and save it by pressing Ctrl-D.
# Using cat, create a file named test3, type "Line3" and save it by pressing Ctrl-D.
  for i in 1 2 3; do
    echo "Line${i}" | cat > "test${i}" # the typing and pressing Ctrl-D is simulated using echo
  done
# Concatenate the files test1 and test2 into a file named newtest.
  cat test1 test2 > newtest
# View the contents of newtest, using cat.
  cat newtest
  echo " "
# Append the file test3 at the end newtest.
  cat test3 >> newtest
# View the contents of the newtest file, using cat.
  cat newtest
  echo " "
# Append the following text to newtest: "Line4".
  echo "Line4" | cat >> newtest # you can even do append
# View the contents of the newtest file, using cat.
  cat newtest
}

setup
lab
cleanup
