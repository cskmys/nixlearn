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
# Try-It-Yourself: Printing With lp
  cat "/etc/updatedb.conf" | enscript -p - | ps2pdf - "testfile.pdf"
# Tasks to be performed:
# Send testfile.pdf to the default printer (a Brother HLL2380DW).
  lp "testfile.pdf"
# Send testfile.pdf to the hp-laserjet printer.
  lp -d "hp-laserjet" "testfile.pdf"
# Print two copies of testfile.pdf on the default printer.
  lp -n 2 "testfile.pdf"
# Set the hp-laserjet as the default printer.
  lpoptions -d "hp-laserjet"
# Check the print queue status.
  lpq -a
}

setup
lab
cleanup
