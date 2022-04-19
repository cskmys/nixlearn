#!/bin/bash

clean_files(){
  find "." -name "*.adoc" -type "f" -exec rm "{}" ";"
}

clean_files

quiz_adoc="quiz.adoc"
if ! [[ -f "${quiz_adoc}" ]]; then
  echo -e "= Quiz\nCSK\n:toc: left\n:sectnums:\n\n\n\n\n\n\n" | head -10 > "${quiz_adoc}" # scripts adds content after the 1st 10 lines
else
  head -10 "${quiz_adoc}" > "${quiz_adoc}".tmp && mv "${quiz_adoc}".tmp "${quiz_adoc}" # done to avoid using "cmd ip_file > ip_file" as you can't read and write in the same line
  # can't do 'head -10 "${quiz_adoc}" | tee "${quiz_doc}"' coz "head" and "tee" run in parallel and the output will be an empty file
  # though output is not empty, can't do 'echo -e "$(head -10 "${quiz_doc}")" > "${quiz_doc}"' as sub-process trims down the additional newline characters
fi

dir_lst=$(find "." -mindepth 1 -maxdepth 1 -type "d" | sort)
ch_lst="$(cat "quiz.txt")"

while read -r cur_dir_path; do
  cur_dir_name=$(basename "${cur_dir_path}")
  cur_quiz_adoc="quiz_${cur_dir_name}.adoc"
  if ! [[ -f "${cur_quiz_adoc}" ]]; then
    cur_ch_nb="$(echo -e "${cur_dir_name}" | sed -e s:"[^0-9]":"":g)"
    cur_ch_name="$(echo "${ch_lst}" | grep -e "${cur_ch_nb}" || echo "Heading")"
    echo -e "== ${cur_ch_name}\n\n\n\n\n\n\n\n\n\n" | head -10 > "${cur_quiz_adoc}"
  else
    head -10 "${cur_quiz_adoc}" > "${cur_quiz_adoc}".tmp && mv "${cur_quiz_adoc}".tmp "${cur_quiz_adoc}"
  fi
  echo -e "include::${cur_quiz_adoc}[]\n" >> "${quiz_adoc}"

  fil_lst=$(find "${cur_dir_path}" -mindepth 1 -maxdepth 1 -type "f" | sort)
  while read -r cur_fil_path; do
    echo -e "image::${cur_fil_path}[]\n" >> "${cur_quiz_adoc}"
  done <<< "${fil_lst}"

done <<< "${dir_lst}"
