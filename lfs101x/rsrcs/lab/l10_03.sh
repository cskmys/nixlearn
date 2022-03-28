#!/bin/bash
get_tmp_dir_name(){
  TMP_DIR_NAME=$(basename "$0" | awk -F"." '{print $1}')
  TMP_DIR_PATH="/tmp/$TMP_DIR_NAME"
}
mk_tmp_dir(){
  mkdir "$TMP_DIR_PATH"
  cd "$TMP_DIR_PATH" || { echo "can't mk_tmp_dir"; exit 1;}
}
rm_tmp_dir(){
  cd /tmp || { echo "can't go to /tmp"; exit 1;}
  rm -r "$TMP_DIR_PATH"
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
  if [[ $opt == "n" ]]; then
    echo "not cleaning up"
    return 0
  fi
  cleanup
}
is_pgm_installed(){
  if which "$1"; then
    return 0
  fi
}
setup_pgm(){
  pgm="$1"
  if [[ (($# -eq 1)) ]]; then
    pkg="$1"
  elif [[ (($# -eq 2)) ]]; then
    pkg="$2"
  else
    echo "provide just binary name if binary name and package name are same or both"
  fi

  if is_pgm_installed "$pgm" "$pkg"; then
    echo "$pgm from $pkg is installed"
    return 0
  fi
  echo "$pkg package needs to be installed for command $pgm"
  sudo apt -y install "$pkg"
}
get_dir_size(){
  dirname=$1
  ls -s --block-size=K "${dirname}" | grep -e "^total .*" | sed -E -e s:"[^0-9]":"":g
}
get_lowest_var(){
  min_var="${1}"
  eval min_val=\$$1
  for i in $*; do
    eval var=\$$i
    if [[ ${var} -lt ${min_val} ]]; then
      min_var=${i}
      min_val=${var}
    fi
  done
}
lab(){
  uncomp_dirname="${PWD}/uncomp/"
  mkdir "${uncomp_dirname}"
  filename="dmesg"
  dmesg | tee "${filename}.txt" | enscript -p - | tee "${filename}.ps" | ps2pdf - "${filename}.pdf"
  mv $PWD/$filename.* $uncomp_dirname
  uncomp_dirsiz=$(get_dir_size "$uncomp_dirname")
  echo "UNCOMP ${uncomp_dirsiz}"
#  ls -s --block-size=K | sed -E -e s:"\s{2,}":" ":g -e s:"^\s":"":g | awk -F" " '{print $1}' | paste -s | sed -E -e s:"[^0-9]":" ":g | sed -E -e s:"\s{2,}":" ":g -e s:"^\s":"":g | awk -F" " '{print $1+$2+$3}'

  tar_dirname="${PWD}/tardir"
  mkdir "${tar_dirname}"
  tar -c ${uncomp_dirname}/* -f "${tar_dirname}/${filename}.tar"
  tar_dirsiz=$(get_dir_size "${tar_dirname}")
  echo "TAR ${tar_dirsiz}"

  gz_dirname="${PWD}/gzdir"
  mkdir "${gz_dirname}"
  gzip < "${tar_dirname}/${filename}.tar" > "${gz_dirname}/${filename}.tar.gz"
  gz_dirsiz=$(get_dir_size "${gz_dirname}")
  echo "GZ ${gz_dirsiz}"

  bzip2_dirname="${PWD}/bzip2dir"
  mkdir "${bzip2_dirname}"
  bzip2 < "${tar_dirname}/${filename}.tar" > "${bzip2_dirname}/${filename}.tar.bz2"
  bzip2_dirsiz=$(get_dir_size "${bzip2_dirname}")
  echo "BZIP2 ${bzip2_dirsiz}"

  xz_dirname="${PWD}/xzdir"
  mkdir "${xz_dirname}"
  xz < "${tar_dirname}/${filename}.tar" > "${xz_dirname}/${filename}.tar.xz"
  xz_dirsiz=$(get_dir_size "${xz_dirname}")
  echo "XZ ${xz_dirsiz}"

  get_lowest_var "uncomp_dirsiz" "tar_dirsiz" "gz_dirsiz" "bzip2_dirsiz" "xz_dirsiz"
  echo "The lowest is ${min_var}=${min_val}"
}

setup
lab
cleanup
