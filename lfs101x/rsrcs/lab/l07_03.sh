#!/bin/bash
FIL=exercise.txt
touch $FIL
mv ./$FIL /tmp
FILPATH=/tmp/$FIL
ls $FILPATH
rm $FILPATH
ls $FILPATH
