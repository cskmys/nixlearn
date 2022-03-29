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
  return 1
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
str2pdf(){
  local str="$1"
  local filename="$2"
  echo "$str" | enscript -p - | ps2pdf - "$filename"
}
get_nb_pdf_pages(){
  local filename="$1"
  local siz
  siz=$(pdfinfo "$filename" | grep -e "Pages" | sed -E -e s:"\s{2,}":" ":g | awk -F" " '{print $2}')
  echo "$siz"
}
lab(){
  setup_pgm "qpdf"

  filename="file"

  str1="$(dmesg)" # use '"$(<cmd>)"' instead of '$(<cmd>)', otherwise you won't
  str2="$(cat /etc/group)"

  str2pdf "$str1" "${filename}1.pdf"
  str2pdf "$str2" "${filename}2.pdf"

  qpdf --empty --pages "${filename}1.pdf" "${filename}2.pdf" -- "${filename}.pdf"

  siz1="$(get_nb_pdf_pages ${filename}1.pdf)"
  siz2="$(get_nb_pdf_pages ${filename}2.pdf)"
  siz="$(get_nb_pdf_pages ${filename}.pdf)"

  if ! [[ $(( siz1 + siz2 )) -eq $siz ]]; then
    echo "failure"
    return 1
  fi
  return 0
}

setup
lab
RET=$?
cleanup
exit $RET
