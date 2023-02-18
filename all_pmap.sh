#!/bin/bash

DIR_PREFIX=/proc/

for dir in `ls /proc/ | grep ^[1-9]`
do
    if [ ! -d $DIR_PREFIX$dir ]
    then
        continue
    fi

    full_path=$DIR_PREFIX$dir
    # echo $full_path
    smaps_full_path=$full_path/smaps
    # echo $smaps_full_path

    for i in `pmap -X $dir|tail -n 1|awk '{print $5}'` ; do sum=$[sum+i]; done
    
    # break
done

sum=$[sum*1014]
echo $sum