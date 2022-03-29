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
# Try-It-Yourself: Using bash Wildcards with ls
  touch gindxbib mkfontscale gio-querymodules-64 mkhybrid [ glib-compile-schemas mkisofs a2p glookbib	mkmanifest ab
  touch glxgears mkrfc2734 abrt-action-analyze-backtrace glxinfo mkxauth abrt-action-analyze-c
  touch gmake mlabel abrt-action-analyze-ccpp-local gneqn mmc-tool
# View all the files in the current directory using ls command with -a option.
  ls -a
# List (using ls) files with names starting with g and containing five letters.
  ls g????
# List (using ls) files whose names begin with mk and end with any characters.
  ls mk*
# List (using ls) files having five letter names starting with g and second character between a-n.
  ls g[a-n]???
# List (using ls) five letter named files starting with g and not having the second character between a-m.
  ls g[!a-m]??? # unlike regex where you would write [^a-m], in glob-ing you write [!a-m]
}

setup
lab
cleanup
