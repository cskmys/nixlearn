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
is_pgm_installed(){
  if which "$1"; then
    return 0
  fi
  return 1
}
setup_pgm(){
  pgm="${1}"
  if [[ (($# -eq 1)) ]]; then
    pkg="${1}"
  elif [[ (($# -eq 2)) ]]; then
    pkg="${2}"
  else
    echo "provide just binary name if binary name and package name are same or both"
  fi

  if is_pgm_installed "${pgm}"; then
    echo "${pgm} from ${pkg} is installed"
    return 0
  fi
  echo "${pkg} package needs to be installed for command ${pgm}"
  sudo apt -y install "${pkg}"
}
lab(){
# Try-It-Yourself: Using Network Tools
  setup_pgm "ethtool"
  setup_pgm "netstat" "net-tools"
# Tasks to be performed:
# Use ethtool to show information about the first network device eth0.
  sudo ethtool enp3s0
# Monitor network traffic in text mode using netstat.
  netstat -r
}

setup
lab
cleanup
