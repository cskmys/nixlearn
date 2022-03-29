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
# Try-It-Yourself: Comparing Files

# In a production environment, you have created a file (MyFile1) with reference to an existing file (MyFile2).
# Your colleague has also created a file (MyFile3) based on the same existing file.
  for n in 1 2 3; do
    echo -e "This data is available in MyFile${n}" > MyFile${n}
  done
# Tasks to be performed:
# Compare the contents of your file and the reference file, using diff.
# Compare the differences between the files created by you and your friend with reference to the existing file, using diff3.
  diff MyFile1 MyFile2
  diff3 MyFile1 MyFile2 MyFile3
}

setup
lab
cleanup
