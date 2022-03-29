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
# Try-It-Yourself: Working with Files and Directories at the Command Prompt

# Using touch, create file1 and file2 (two empty files)
  touch "file1" "file2"
# Check for the existence of file1 and file2 using ls -l .
  ls -l "file1" "file2" # to check specifically for existence using ls, you can pass the file name as argument
# Rename file1 to new_file1 using mv.
  mv "file1" "new_file1"
# Remove file2 using rm without any options.
  rm "file2"
# Remove new_file1 using rm without any options.
  rm "new_file1"
# Create a directory named dir1, using mkdir.
  mkdir "dir1"
# Remove dir1 using rmdir without any options.
  rmdir "dir1"
}

setup
lab
cleanup
