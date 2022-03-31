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
# Try-It-Yourself: Locating Files

# Find all files with the extension .doc.
  locate ".doc" | grep -e ".doc$"
# Copy the file named pdb.doc from /usr/lib/python2.7 to the current working directory as Myfile.doc.
  cp "/usr/lib/python2.7/pdb.doc" "Myfile.doc"
# Update the database used by locate by running updatedb.
  sudo updatedb
# Locate the file Myfile.doc. (Remember that filenames are case sensitive!).
  locate "Myfile.doc"
  # file "/etc/updatedb.conf" has the line:
  # 'PRUNEPATHS="/tmp /var/spool /media /var/lib/os-prober /var/lib/ceph /home/.ecryptfs /var/lib/schroot"'
  # "Myfile.doc" is in "/tmp/<script_basename>/" so, database is not updated with its files n directories
  # hence, you don't see it in the result

  # now we will override the default pruning path to remove "/tmp" so that database is updated with "Myfile.doc" and it shows up when we run "locate"
  new_prunepaths=$(grep -e "PRUNEPATHS" "/etc/updatedb.conf" | sudo sed -e s:"/tmp ":"":g -e s:"PRUNEPATHS=":"":g)
  sudo updatedb --prunepaths "${new_prunepaths}"
  locate "Myfile.doc"

  sudo updatedb
  locate "Myfile.doc"
}

setup
lab
cleanup
