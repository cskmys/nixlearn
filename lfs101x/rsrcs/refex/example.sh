#!/bin/bash
# Comments in shell start with a '#' symbol
# but '#!' in the first line is an exception to this as it is used to specify shell

if ! [[ (( (( -x "/usr/bin/sed" )) && (( -x "/usr/bin/grep" )) )) ]] || ! { which "cat" > "/dev/null" && which "less" > "/dev/null";}; then exit 1; fi
# here we have the condition checking of the form: '![[]] || !{}'
# whenever, the outermost braces are '[[  ]]', the inner braces are '(( ))', and anything that starts with '[[]]' is expected to evaluate using flags,
# hence you cannot evaluate a return value of a program(here 'which' for example).
# therefore, '{}' is used

# '>' in 'which "cat" > "dev/null"' means the output of 'which "cat"' is redirected to file '/dev/null' and not displayed on the terminal
# whenever redirection to file is used, if the file doesn't exist, it is created
# 'dev/null' is a pseudo-file that exists already exists under the root file system and writing to it does nothing
# hence, it is used to silence the output of the preceding program=

too_much=3 # variable can be just declared as '<var_name>=<var_value>' but remember to not have space before and after the '='
case "${#}" in # '$#' indicates number of command line arguments provided by the user,
               # that means the default argument '$0' referring to filename of script is not included in the count

               # it is good practice to enclose all variables using '{}' and '""', like we have enclosed '$#' as '"${#}"'
               # enclosing it in '{}' ensures that it is distinguished from another string if it exists
               # enclosing it in '""' ensures that it is not globed.
  "0") echo "no argument";; # every case within 'case' statement needs to be ended with ';;'
  "1") echo "just one argument of length ${#1}"; # the '#' in '$#1' indicates the length of string '$1'
                                                 # the '1' in '$1' refers to the 1st command line argument entered by the user
                                                 # the 0th argument is always by default the full name of the script that is being run
                                                 # individual statements within a case can be seperated by ';'
       echo "All the characters after the / are ${1#*/}";; # the '#*/' in '$1#*/' indicates all the characters until the end of the '$1' starting from '/'
  "2") echo "proper number of arguments";
       if [[ "${1}" > "${2}" ]]; then # string can be compared using operators such as '>', '<' and '==' but needs to be enclosed within '[[]]'
                                      # the operator '>' just checks if the two strings are in an descending order of sorting
         echo "argument 1 succeeds 2"
       elif [[ "${1}" == "${2}" ]]; then
         echo "argument 1 equals 2"
       else
         echo "argument 1 precedes 2"
       fi;;
  *)  j="1";
      fact="1";
      if [[ "${#}" -gt "${too_much}" ]]; then # variables are used as $<var_name>,
        echo "too many arguments given"
        while [[ "${j}" -le "${#}" ]]; do # while <condition> is true execute
          fact=$(( "${fact}" * "${j}" )) # all math operations are done using construct '$(( ))'
                                         # note that there is no space on either side of '='
          j=$(( "${j}" + 1 ))
        done
        for arg in "${@}"; do # iterating over an array using "for"
                              # '$@' gives all the command line arguments entered by the user(meaning the default 0th argument is omitted) in the form of an array
          echo "argument: ${arg}"
        done
      else
        until [[ "${j}" -gt "${#}" ]]; do # until a <condition> becomes true execute, opposite of while
          fact=$(( "${fact}" * "${j}" ))
          j=$(( "${j}" + 1 ))
        done
        for arg in "${1}" "${2}" "${3}"; do # building an in-place list over which iteration is done using "for"
          echo "argument: ${arg}"
        done
      fi;
      echo "the factorial of number of arguments is ${fact}";;
esac

tmp_dir=$(mktemp -d "/tmp/ex.XXX") # to capture a program's output in a variable: '<var_name>=$(<cmd>)'
ls_op=$(mktemp "${tmp_dir}/ls_op.XXX")
# '\' below indicates continuation of same command to a new line
echo "${0} ${*}" \
>> "${ls_op}" # hence, above can be written as 'echo "${0} ${*}" >> "${ls_op}"'
              # '$*' in 'echo "${0} ${*}"' refers to all arguments typed by the user as a single string, meaning the default 0th argument is omitted in '$*'
              # hence, we manually provide '$0' in 'echo "${0} ${*}"' to include default 0th argument as well
              # '>>' in 'echo "${0} ${*}" >> "${ls_op}"' indicates redirection of output of 'echo "${0} ${*}"' to a file '$ls_op' while appending it(if it exists or creating it otherwise)
echo "#" >> "${ls_op}" # if you had just written 'echo # >> "${ls_op}"', writing '#' without enclosing it in "" everything after '#' i.e. '>> "${ls_op}"' would have been considered as comments

my_func(){
  echo "before shift"
  echo "0:${0} 1:${1}" # '$1' is now the first argument passed to the function not the command line argument
                   # '$0' as usual contains the default 0th argument even inside a function
  local op_fil="${1}"
  shift # when nothing is passed it shifts by 1 position
  # after shift '$0' is untouched, '$1' is lost and '$2' is moved to '$1' and '$3' is moved to '$2', and so on
  echo "after shift" # here after shift '$1' is lost
  # as there is only one argument passed to this function, there is no '$2' to move to '$1', hence '$1' is now empty
  echo "0:${0} 1:${1}"

  { echo "/lib/modules/$(uname -r)/"*modules* | sed -e s:" ":"\n":g; echo "${tmp_dir}";} >> "${op_fil}" # curly braces '{}' can be used to build compound statements from multiple statements
# when you use curly braces '{}', be careful coz there needs to be a space right after the opening curly brace and every statement within the curly brace must end with ';'
# you can use ">>" at the end of one compound statement instead of each statement inside it

# '|' in 'echo "/lib/modules/$(uname -r)/"*modules* | sed -e s:" ":"\n":g' indicates output of 'echo "/lib/modules/$(uname -r)/"*modules*' is sent as input to 'sed' program
# 'sed -e s:" ":"\n":g' uses ':' as a separator in its command

# note that in 'echo "/lib/modules/$(uname -r)/"*modules*', in the argument '"/lib/modules/$(uname -r)/"*modules*',
# a part of if it is enclosed in '""', while the remaining part with wildcards is not enclosed in '""'
# this is intentional, for the part that we don't want to split or glob, we enclose it with '""' and
# for the part that with wildcard we are letting it split or glob by not enclosing  it with '""'

# 'tmp_dir' which is declared above the function is visible inside the function
# even 'op_fil' which is declared inside the function would have been visible outside it if we didn't use the keyword 'local' while declaring it
}
my_func "${ls_op}" # calling a function and passing an argument

ret=0
my_pgm="less"
{ ls "${1}" | grep "kde" && echo "${PATH}" | sed -e s/":"/"\n"/g | grep "${2}";} >> "${ls_op}" || { ret="${?}"; my_pgm="cat";}
# effectively this is of the form '(((a) && (b)) || (c))' but we don't put those parenthesis as parenthesis in shell scripting has a different meaning
# hence, if '(a)' is true '(b)' is executed, otherwise '(c)' is executed
# if '(b)' was executed and is true, '((a) && (b))' is true, and hence '(c)' is ignored
# otherwise, '((a) && (b))' is false, and hence '(c)' is executed
# therefore, if 'ls "${1}" | grep "kde"' is successful, 'echo "${PATH}" | sed -e s/":"/"\n"/g | grep "${2}"' is executed, otherwise '{ ret="${?}"; my_pgm="cat";}' is executed
# if 'echo "${PATH}" | sed -e s/":"/"\n"/g | grep "${2}"' is executed and successful, '{ ret="${?}"; my_pgm="cat";}' is ignored, otherwise '{ ret="${?}"; my_pgm="cat";}' is executed

# consider, 'ls "${1}" | grep "kde"', it will be a success only if the output of 'ls "${1}"' contains the string 'kde'

# consider, 'echo "${PATH}" | sed -e s/":"/"\n"/g | grep "${2}"', 'PATH' is an environment variable and to access it, '$PATH' is used

# consider 'ret=$?' in '{ ret="${?}"; my_pgm="cat";}', the return value of last executed command(here it is 'ls "${1}" | grep "kde"' upon it's failure or 'echo "${PATH}" | sed -e s/":"/"\n"/g | grep "${2}"' upon its failure)
# is accessed using '$?'

# note when you are 100% sure that certain files/directories exists, then do 'echo <dir>/*<partial_name>*' to use the in-built 'glob'-ing feature of the shell
# if you want to check if a file or directory with a certain pattern exists or not, then do 'ls <dir> | grep <partial_name>' coz
# if it exists 'grep' will exit with 0 causing 'ls <dir> | grep <partial_name>' to be success otherwise the vice-versa

echo "my program is ${my_pgm}"
echo "the 2 letters from the 2nd character in my program's name is \"${my_pgm:1:2}\"" # '${<string>:<offset>:<nb_char>}' will print '<nb_char>' nb of characters starting from '<offset>' position in the string
$my_pgm < "${ls_op}"
# '<' in '$my_pgm < "${ls_op}"' indicates redirecting file '$ls_op' contents as input to '$$my_pgm' program
# this is different from doing '$$my_pgm ls_op' where we let '$$my_pgm' program to open the file and access its contents
rm -r "${tmp_dir}"
exit "${ret}" # Upon success `0` is returned and a non-zero value upon failure
              # you can do 'echo $?' in the terminal right after running the script to check the return value/lib/modules/5.4.0-107-generic/modules.alias
/lib/modules/5.4.0-107-generic/modules.alias.bin
/lib/modules/5.4.0-107-generic/modules.builtin
/lib/modules/5.4.0-107-generic/modules.builtin.alias.bin
/lib/modules/5.4.0-107-generic/modules.builtin.bin
/lib/modules/5.4.0-107-generic/modules.builtin.modinfo
/lib/modules/5.4.0-107-generic/modules.dep
/lib/modules/5.4.0-107-generic/modules.dep.bin
/lib/modules/5.4.0-107-generic/modules.devname
/lib/modules/5.4.0-107-generic/modules.order
/lib/modules/5.4.0-107-generic/modules.softdep
/lib/modules/5.4.0-107-generic/modules.symbols
/lib/modules/5.4.0-107-generic/modules.symbols.bin
/tmp/ex.8T8
/lib/modules/5.4.0-107-generic/modules.alias
/lib/modules/5.4.0-107-generic/modules.alias.bin
/lib/modules/5.4.0-107-generic/modules.builtin
/lib/modules/5.4.0-107-generic/modules.builtin.alias.bin
/lib/modules/5.4.0-107-generic/modules.builtin.bin
/lib/modules/5.4.0-107-generic/modules.builtin.modinfo
/lib/modules/5.4.0-107-generic/modules.dep
/lib/modules/5.4.0-107-generic/modules.dep.bin
/lib/modules/5.4.0-107-generic/modules.devname
/lib/modules/5.4.0-107-generic/modules.order
/lib/modules/5.4.0-107-generic/modules.softdep
/lib/modules/5.4.0-107-generic/modules.symbols
/lib/modules/5.4.0-107-generic/modules.symbols.bin
/tmp/ex.ngE
