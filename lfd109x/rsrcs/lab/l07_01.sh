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
lab(){
  my_echo "initializing git"
  git init
  git config user.name "csk"
  git config user.email "csk@nix.com"
  echo ""

  nb_upd=64
  my_echo "creating ${nb_upd} commits"
  j_init=0
  j="${j_init}"
  rand=$(("${RANDOM}"%"${nb_upd}"))
  file_name="file"
  while [[ "${j}" -lt "${nb_upd}" ]]; do
    cur_fil_str="GOOD"
    if [[ "${j}" -eq "${rand}" ]]; then
      cur_fil_str="BAD"
      my_echo "BAD one is ${j}"
    fi
    cur_file_name="${file_name}${j}"
    echo "${cur_fil_str}" > "${cur_file_name}"

    git add "${cur_file_name}"
    git commit -s -m "adding ${cur_file_name}" > "/dev/null"
    git tag "${cur_file_name}"

    j=$(( "${j}" + 1 ))
  done

#  git log --pretty=oneline

  my_echo "starting bisecting procedure(manual)"
  git bisect start
  git bisect bad
  first_file="${file_name}${j_init}"
  git bisect good "${first_file}"

  j=0
  bis_op_file="git_out"
  while [[ "${j}" -eq "0" ]]; do
    if [[ "$(grep "BAD" ${file_name}*)" == "" ]]; then
      git bisect good | tee "${bis_op_file}" | grep -i "bad"
    else
      git bisect bad | tee "${bis_op_file}" | grep -i "bad"
    fi
    if [[ "$(grep "revisions left" "${bis_op_file}")" == "" ]]; then
      j=1
    fi
  done
#  git bisect log
  git bisect reset


  my_echo "starting bisecting procedure(auto)"

  echo '#!/bin/bash
  if [[ "$(grep "BAD" file*)" == "" ]]; then
    exit 0
  fi
  exit 1
  ' > check.sh

  chmod +x check.sh

  git bisect start
  git bisect bad
  first_file="${file_name}${j_init}"
  git bisect good "${first_file}"

  git bisect run ./check.sh | grep -i "bad"
#  git bisect log
  git bisect reset
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
