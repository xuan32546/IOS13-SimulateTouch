#!/bin/bash
echo "`date "+%m-%d-%Y %T"`: Start running script. Script path: $1"
while read line;
do
   echo "`date "+%m-%d-%Y %T"`: $line";
done
