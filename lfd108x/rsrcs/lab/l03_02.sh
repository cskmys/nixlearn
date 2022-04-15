#!/bin/bash
mk_tmp_dir(){
  TMP_DIR_NAME=$(basename "${0}" | awk -F"." '{print $1}')
  TMP_DIR_PATH=$(mktemp -d "/tmp/${TMP_DIR_NAME}.XXX")
  cd "${TMP_DIR_PATH}" || { echo "can't mk_tmp_dir"; exit 1;}
}
prj_setup(){
  mkdir -p "./src/A/b"
  mkdir -p "./src/A/a/X"
  mkdir -p "./src/B"
  touch "./src/A/0"
  touch "./src/A/1"
  touch "./src/A/2"
  touch "./src/A/b/0"
  touch "./src/A/a/X/0"
  touch "./src/A/a/X/1"

  mkdir "./dst"
}
setup(){
  mk_tmp_dir
  prj_setup
}
rm_tmp_dir(){
  cd "/tmp" || { echo "can't go to /tmp"; exit 1;}
  rm -r "${TMP_DIR_PATH}"
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
  pgm="${1}"
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
print_dir_contents(){
  print_dir="${1}"
  print_dir_name="${2}"
  echo "${print_dir_name} dir:"
  find "${print_dir}" -type "d"
  echo ""
  echo "${print_dir_name} file:"
#  find "${print_dir}" -type "d" -exec find "{}" -maxdepth 1 -type "f" ';'
  find "${print_dir}" -type "d" -exec bash -c 'op=$(find "${1}" -maxdepth 1 -type "f"); if ! [[ ((-z "${op}")) ]]; then echo "${op}"; echo ""; fi;' shell {} ";"
  echo ""
}
print_src_dst_dir(){
  local src_dir="${1}"
  local dst_dir="${2}"
  print_dir_contents "${src_dir}" "source"
  print_dir_contents "${dst_dir}" "destination"
}
print_dst_dir(){
  local dst_dir="${1}"
  print_dir_contents "${dst_dir}" "destination"
}
lab(){
  src_dir="./src"
  dst_dir="./dst"

  print_src_dst_dir "${src_dir}" "${dst_dir}" > "./before"
  find "${src_dir}" -type "d" -exec bash -c '
    cur_src_dir="${1}"
    dst_dir="${2}"
    cur_dst_dir="${dst_dir}/${cur_src_dir}"
    mkdir "${cur_dst_dir}"
    cur_src_dir_fil_lst=$(find "${cur_src_dir}" -maxdepth 1 -type "f" | xargs echo)
    if ! [[ (( -z "${cur_src_dir_fil_lst}" )) ]]; then
      tar -z -c $cur_src_dir_fil_lst -f "${cur_dst_dir}/backup.tar.gz"
    fi
  ' shell {} "${dst_dir}" ";" # creating source directory structure in destination directory
  print_src_dst_dir "${src_dir}" "${dst_dir}" > "./after"
  echo "1"
  diff "./before" "./after"

#  touch "./src/A/2"
#
#  print_src_dst_dir "${src_dir}" "${dst_dir}" > "./before2"
#  dst_backup_dir=$(find "${dst_dir}" -name "$(basename "${src_dir}")")
#  find "${src_dir}" -type "d" -newer "${dst_backup_dir}" -exec bash -c '
#    cur_src_dir="${1}"
#    dst_dir="${2}"
#    cur_dst_dir="${dst_dir}/${cur_src_dir}"
#    cur_src_dir_fil_lst=$(find "${cur_src_dir}" -maxdepth 1 -type "f" | xargs echo)
#    echo "${cur_src_dir_fil_lst}"
#  ' shell {} "${dst_dir}" ";" # creating source directory structure in destination directory
#  print_src_dst_dir "${src_dir}" "${dst_dir}" > "./after2"
#  echo "2"
#  diff "./before2" "./after2"
#
##    if ! [[ (( -z "${cur_src_dir_fil_lst}" )) ]]; then
##      tar -z -c $cur_src_dir_fil_lst -f "${cur_dst_dir}/backup.tar.gz"
##    else
##      rm -f "${cur_dst_dir}/backup.tar.gz"
##    fi
}

setup
lab "${@}"
ret="${?}"
cleanup
exit "${ret}"
