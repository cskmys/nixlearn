#!/bin/bash

{ echo "$*"; echo "#"; echo "$0"; echo "\#";} >> ls_op

{ ls /; echo '#';} >> ls_op

{ echo /lib/modules/"$(uname -r)"/*modules* && echo $#;} >> ls_op

MY_PRG=less
{ ls "$1" | grep kde && echo "$PATH" | grep "$2";} >> ls_op || MY_PRG=cat

echo my program is $MY_PRG
$MY_PRG < ls_op
