#!/bin/bash
ls /abc
echo $?
touch ./abc
ls ./abc
echo $?
rm ./abc

