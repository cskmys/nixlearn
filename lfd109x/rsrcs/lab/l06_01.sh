#!/bin/bash

mk_tmp_dir(){
  TMP_DIR_NAME=$(basename "${0}" | awk -F"." '{print $1}')
  TMP_DIR_PATH=$(mktemp -d "/tmp/${TMP_DIR_NAME}.XXX")
  cd "${TMP_DIR_PATH}" || { echo "can't mk_tmp_dir"; exit 1;}
}
rm_tmp_dir(){
  cd "/tmp" || { echo "can't go to /tmp"; exit 1;}
  rm -rf "${TMP_DIR_PATH}"
}
setup(){
  mk_tmp_dir
}
cleanup(){
  rm_tmp_dir
}
cleanup_w_permission(){
  echo "You want to cleanup[*/n]?"
  read -r opt
  opt=$(echo "${opt}" | tr "[:upper:]" "[:lower:]")
  case "${opt}" in
    "no" | "n") echo "not cleaning up";;
    *) cleanup;;
  esac
}
exit_func(){
  cleanup
  [[ -z "${1}" ]] && exit "0" || exit "${1}"
}
is_pgm_installed(){
  if which "${1}"; then
    return 0
  fi
  return 1
}
setup_pgm(){
  local pgm="${1}"
  local pkg=""
  if [[ ((${#} -eq 1)) ]]; then
    pkg="${1}"
  elif [[ ((${#} -eq 2)) ]]; then
    pkg="${2}"
  else
    echo "provide just binary name if binary name and package name are same or both"
  fi

  if is_pgm_installed "${pgm}" "${pkg}"; then
    echo "${pgm} from ${pkg} is installed"
    return 0
  fi
  echo "${pkg} package needs to be installed for command ${pgm}"
  sudo apt -y install "${pkg}"
}
my_echo(){
#  Black        0;30     Dark Gray     1;30
#  Red          0;31     Light Red     1;31
#  Green        0;32     Light Green   1;32
#  Brown/Orange 0;33     Yellow        1;33
#  Blue         0;34     Light Blue    1;34
#  Purple       0;35     Light Purple  1;35
#  Cyan         0;36     Light Cyan    1;36
#  Light Gray   0;37     White         1;37
  PURPLE='\033[0;35m'
  NC='\033[0m' # No Color
  echo -e "${PURPLE}${1}${NC}"
}
commit_log(){
  echo ""
  my_echo "commit changes"
  git commit -s -m "${1}"
  git status
  echo ""
  my_echo "repo history"
  git log
  echo ""
}
lab(){
  my_echo "initializing git"
  git init
  git config user.name "csk"
  git config user.email "csk@nix.com"
  echo ""

  my_echo "add files"
  echo > "file1"
  echo > "file2"
  git status
  git add "file1" "file2"
  git status
  commit_log "adding file1 file2"

  my_echo "removing with rm"
  rm "file2"
  git status
  git rm "file2"
  git status
  commit_log "removing file2"

  my_echo "moving with mv"
  mv "file1" "file"
  git status
  git rm "file1"
  git status
  git add "file"
  git status
  commit_log "renaming file1 to file"

  my_echo "moving with git mv"
  git mv "file" "fiche"
  git status
  commit_log "renaming file to fiche"

  my_echo "removing with git rm"
  git rm "fiche"
  git status
  commit_log "removing fiche"
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
