#!/bin/bash
echo "enter 1 or 2"
read nb
if [[ $nb -eq 1 ]]; then
  YN="YES"
elif [[ $nb -eq 2 ]]; then
  YN="NO"
else
  echo "You need to enter 1 or 2"
  exit 1
fi
export YN
echo $YN
