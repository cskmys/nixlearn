#!/bin/bash
get_tmp_dir(){
  TMP_DIR_NAME=$(basename "${0}" | awk -F"." '{print $1}')
}
mk_tmp_dir(){
  TMP_DIR_PATH=$(mktemp -d "/tmp/${TMP_DIR_NAME}.XXX")
  cd "${TMP_DIR_PATH}" || { echo "can't mk_tmp_dir"; exit 1;}
}
rm_tmp_dir(){
  cd "/tmp" || { echo "can't go to /tmp"; exit 1;}
  rm -rf "${TMP_DIR_PATH}"
}
setup(){
  get_tmp_dir
  cp "./${TMP_DIR_NAME}.c" "/tmp"
  cp "./${TMP_DIR_NAME}" "/tmp"
  mk_tmp_dir
  mv "/tmp/${TMP_DIR_NAME}.c" "/${TMP_DIR_PATH}/myhello.c"
  mv "/tmp/${TMP_DIR_NAME}" "/${TMP_DIR_PATH}/Makefile"
  echo "README" > "/${TMP_DIR_PATH}/README"
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
#  setup_pgm "dh-make"
#  setup_pgm "fakeroot"
#  setup_pgm "build-essential"

  prj="myhello"
  pkg="${prj}-1.0"
  src_path="${TMP_DIR_PATH}/${pkg}"
  mkdir "${src_path}"
  mv "${TMP_DIR_PATH}/myhello.c" "${src_path}"
  mv "${TMP_DIR_PATH}/Makefile" "${src_path}"
  mv "${TMP_DIR_PATH}/README" "${src_path}"

  zip_file="${TMP_DIR_PATH}/${pkg}.tar.gz"
  tar -czvf "${zip_file}" "./${pkg}"

  echo ""
  echo "initial"
  echo "${TMP_DIR_PATH}"
  ls -l "${TMP_DIR_PATH}"
  echo "${src_path}"
  ls -l "${src_path}"
  echo "${zip_file}"
  tar -tvf "${zip_file}"
  echo ""

  cd "./${pkg}" || exit_func "1"
  dh_make -f "../${pkg}.tar.gz"
  dpkg-buildpackage -uc -us
  "./${prj}"

  echo ""
  echo "final"
  echo "${TMP_DIR_PATH}"
  ls -l "${TMP_DIR_PATH}"
  echo "${src_path}"
  ls -l "${src_path}"
  echo "${zip_file}"
  tar -tvf "${zip_file}"
  echo "debian"
  ls ../*.deb
  dpkg --contents ../*.deb
  echo ""

  echo "install, uninstall"
  cd ".."
  sudo dpkg --install *.deb
  "${prj}"
  sudo dpkg --remove "${prj}"
  "${prj}"
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
