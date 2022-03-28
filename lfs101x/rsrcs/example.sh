#!/bin/bash
# Comments in shell start with a '#' symbol
# but '#!' in the first line is an exception to this as it is used to specify shell

if ! [[ (( (( -x /usr/bin/sed )) && (( -x /usr/bin/grep )) )) && (( (( -x /usr/bin/echo )) || (( -x /usr/bin/lessecho )) )) ]]; then exit 1; fi
# the outer most are [[  ]], while the inner ones are (( ))
Nb_ARG_REQ=2
if [[ $# -eq $Nb_ARG_REQ ]]; then
  echo
  echo proper number of arguments
elif [[ $# -gt $Nb_ARG_REQ ]]; then
  echo $(($# * 100/Nb_ARG_REQ)) of arguments
else
  echo too less of arguments
fi

echo $* > ls_op # '>' indicates redirection of output of 'echo $*' to a file 'ls_op' while overwriting it(if it exists or creating it otherwise)
# '$*' in 'echo $*' refers to all arguments typed by the user(meaning the default 0th argument is omitted)
echo \# >> ls_op # '>>' in 'echo \# >> ls_op' indicates redirection of output of 'echo \#' to a file 'ls_op' while appending it(if it exists or creating it otherwise)
# in 'echo \#' character '#' is written as '\#' to distinguish it from a comment

# '\' below indicates continuation of same command to a new line
echo $0 \
>> ls_op # hence, above can be written as 'echo $0 >> ls_op'
# '$0' in 'echo $0' is the default 0th argument which contains the script name
echo '\#' >> ls_op; ls / >> ls_op; echo '#' >> ls_op # ';' indicates another command (in the same line) to be executed next irrespective of exit status of the previous command
# hence, 'echo '\#' >> ls_op; ls / >> ls_op; echo '#' >> ls_op' can be written as 3 lines:
# echo '\#' >> ls_op
# ls / >> ls_op
# echo '#' >> ls_op

my_func(){
{ echo /lib/modules/$(uname -r)/*modules* | sed -e s:" ":"\n":g; echo $#;} >> ls_op # when you use curly braces '{}', be careful coz
# there needs to be a space right after the opening curly brace and every statement within the curly brace must end with ';'
# you can combine multiple statements that end with ">>" into one compound statement ending with ">>" using "{}"

# '$()' in '$(uname -r)' means execute 'uname -r' and use its output value like you would use a value of a variable
# hence, '$(uname -r)' in 'ls /lib/modules/$(uname -r)' is equivalent to 'ls /lib/modules/<uname -r result>'
# '|' in 'echo /lib/modules/$(uname -r)/*modules* | sed s:" ":"\n":g' indicates output of 'echo /lib/modules/$(uname -r)/*modules*' is sent as input to 'sed' program
# 'sed -e s:" ":"\n":g' uses ':' as a separator in its command
# '$#' in 'echo $# >> ls_op' refers to the number of arguments that the user supplied(that means the default argument $0 referring to filename of script is not included in the count)
}

my_func # function invocation


RET=0 # local variable 'RET' is created with value '0'
# note that there should not be any space before and after the '='
MY_PRG=less
{ ls $1 | grep kde && echo $PATH | sed -e s/":"/"\n"/g | grep $2;} >> ls_op || { RET=$?; MY_PRG=cat;}
# effectively this is of the form '(((a) && (b)) || (c))' but we don't put those parenthesis as parenthesis in shell scripting has a different meaning
# hence, if '(a)' is true '(b)' is executed, otherwise '(c)' is executed
# if '(b)' was executed and is true, '((a) && (b))' is true, and hence '(c)' is ignored
# otherwise, '((a) && (b))' is false, and hence '(c)' is executed
# therefore, if 'ls $1 | grep kde' is successful, 'echo $PATH | grep $2' is executed, otherwise 'MY_PRG=cat' is executed
# if 'echo $PATH | grep $2' is executed and successful, 'MY_PRG=cat' is ignored, otherwise 'MY_PRG=cat' is executed

# consider, 'ls $1 | grep kde', '$1' in 'ls $1' is the first argument given by user while running the script
# 'ls $1 | grep kde' will be a success only if the output of 'ls $1' contains the string 'kde'
# consider, 'echo $PATH | grep $2', 'PATH' is an environment variable and to access it, '$PATH' is used
# consider `RET=$?`, the return value of last executed command(here it is 'ls $1 | grep kde' upon failure or 'echo $PATH | sed -e s/":"/"\n"/g | grep $2' upon its failure)
# is accessed using `$?`

# note when you are 100% sure that certain files/directories exists, then do 'echo <dir>/*<partial_name>*' to use the in-built 'glob'-ing feature of the shell
# if you want to check if a file or directory with a certain pattern exists or not, then do 'ls <dir> | grep <partial_name>' coz
# if it exists 'grep' will exit with 0 causing 'ls <dir> | grep <partial_name>' to be success otherwise the vice-versa

echo my program is $MY_PRG # local variable is accessed just like environment variable
$MY_PRG < ls_op
# '<' in '$MY_PRG < ls_op' indicates redirecting file 'ls_op' contents as input to '$MY_PRG' program
# this is different from doing '$MY_PRG ls_op' where we let '$MY_PRG' program to open the file and access its contents
exit $RET # Upon success `0` is returned and a non-zero value upon failure
# you can do 'echo $?' right after running the script to check the return value
