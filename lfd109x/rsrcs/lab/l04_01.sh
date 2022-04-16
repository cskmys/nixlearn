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
  echo "before git"
  ls -la
  echo ""
  echo "initializing git"
  git init
  echo ""
  echo "after git"
  ls -la
  echo ""
  echo "configuring author"
  git config user.name "csk"
  git config user.email "csk@nix.com"
  echo ""
  file_mod="file1"
  file_const="file2"
  echo "add files"
  echo "abc" > "${file_mod}"
  echo "xyz" > "${file_const}"
  ls -la
  git add "${file_mod}" "${file_const}"
  echo ""
  echo "commit file"
  git commit -s -m "files are added"
  echo ""
  echo "modifying file"
  echo "pqr" > "${file_mod}"
  echo ""
  echo "checking for changes"
  git diff
  echo ""
  echo "adding changes"
  git add "${file_mod}"
  echo ""
  echo "checking for any other changes"
  git diff
  echo ""
  echo "committing added changes"
  git commit -s -m "${file_mod} updated"
  echo ""
  echo "repo current status"
  git status
  echo ""
  echo "repo history"
  git log
  echo ""
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
