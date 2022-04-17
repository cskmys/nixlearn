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
  case "${opt}" in
    "no" | "NO" | "No" | "nO" | "n" | "N") echo "not cleaning up";;
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
lab(){
  ls -l > "./d_before"

  echo "current git version"
  git --version
  echo ""

  git clone -v "https://github.com/git/git.git" # takes a lot of time

  ls -l > "./d_after"

  cd "git" || exit_func "1"
  echo "downloaded git version"
  git tag
  git log

  ls -l > "./c_before"

  echo "compiling git"
  make NO_CURL=1 NO_EXPAT=1 NO_SSL=1 # compiling Git with lesser features
  # will not be installing: make install

  ls -l > "./c_after"

  echo ""
  echo "changes in work directory"
  diff "../d_before" "../d_after"
  echo "changes in git source directory"
  diff "./c_before" "./c_after"
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"