#!/bin/bash
exit_func(){
  echo "You need to enter a character among(a,s,m,d) and 2 numbers"
  exit 1
}
check_re(){
  re=$1
  var=$2
  if ! [[ $var =~ $re ]]; then
      return 1
  fi
  return 0
}
check_nb(){
  re='^[+-]?[0-9]+([.][0-9]+)?$'
  check_re $re $1
  return $?
}
check_char(){
  re='\b[asmd]\b'
  check_re $re $1
  return $?
}
if [[ $# -ne 3 ]]; then
  echo "not proper nb of arguments"
  exit_func;
else
  check_char $1
  is_ch=$?
  check_nb $2
  is_n1=$?
  check_nb $3
  is_n2=$?
  if [[ $((is_ch+is_n1+is_n2)) -ne 0 ]]; then
    echo "invalid arguments"
    exit_func;
  fi
fi
add(){
  echo "sum: $(($1+$2))"
}
sub(){
  echo "difference: $(($1-$2))"
}
mul(){
  echo "product: $(($1*$2))"
}
div(){
  echo "quotient: $(($1/$2))"
}
ch=$1
n1=$2
n2=$3
if [[ $ch == 'a' ]]; then
  add $n1 $n2
elif [[ $ch == 's' ]]; then
  sub $n1 $n2
elif [[ $ch == 'm' ]]; then
  mul $n1 $n2
elif [[ $ch == 'd' ]]; then
  div $n1 $n2
fi
