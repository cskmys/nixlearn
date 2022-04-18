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
mk_add_files(){
  local file_name="${1}"
  local nb_files="${2}"
  local j=0
  while [[ "${j}" -lt "${nb_files}" ]]; do

    cur_file_name="${file_name}${j}"
    echo "${cur_file_name}" > "${cur_file_name}"
    git add "${cur_file_name}"

    j=$(( "${j}" + 1 ))
  done
}
mk_add_commit(){
  local file_name="${1}"
  local nb_files=${2}
  my_echo "adding files"
  mk_add_files "${file_name}" "${nb_files}"

  my_echo "commit"
  git commit -s -m "adding ${file_name}s" > "/dev/null"
}
op_files(){
  my_echo "check file contents"
  find "." -maxdepth 1 -type "f" -exec bash -c '
    cur_file_name="${1}"
    COL="${2}"
    NC="${3}"
    echo -e "${COL}${cur_file_name}${NC}"
    cat "${cur_file_name}"
  ' shell {} '\033[0;36m' '\033[0m' ";"
}
ls_files(){
  my_echo "list files"
  ls -l
  git ls-files
}
lab(){
  my_echo "initializing git"
  git init
  git config user.name "csk"
  git config user.email "csk@nix.com"
  echo ""

  file_name="file"
  mk_add_commit "${file_name}" 5

  ls_files

  op_files

  my_echo "mk and switch branch"
  branch_name="devel"
  git branch "${branch_name}"
  git checkout "${branch_name}"
  git branch

  my_echo "modifying files"
  # 0: content addition, 1: content deletion, 2: content change, 3: rename file, 4: delete file, 5: add file
  echo "${file_name}0" >> "${file_name}0"

  echo > "${file_name}1"

  echo "${file_name}" > "${file_name}2"

  git mv "${file_name}3" "${file_name}3_re"
  git rm "${file_name}4"

  echo "${file_name}5" >> "${file_name}5"
  git add "${file_name}0" "${file_name}1" "${file_name}2" "${file_name}5"

  my_echo "commit"
  git commit -s -m "adding ${file_name}s" > "/dev/null"

  ls_files

  op_files

  my_echo "switch branch"
  git checkout "master"
  git branch

  ls_files

  op_files

  my_echo "merge ${branch_name} into master"
  git merge "${branch_name}"

  ls_files

  op_files
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
