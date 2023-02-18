#!/bin/bash
DIR_PREFIX=/proc/
DEBUG=true

function debug_echo() 
{
    if [[ $DEBUG == true ]]
    then
        echo $1$2
    fi
}

PSS_SIZE=0
RSS_SIZE=0
PD_SIZE=0
Ref_SIZE=0
Anon_SIZE=0
LOCK_SIZE=0
for dir in `ls /proc/ | grep ^[1-9]`
do
    if [ ! -d $DIR_PREFIX$dir ]
    then
        continue
    fi

    full_path=$DIR_PREFIX$dir
    debug_echo $full_path
    smaps_full_path=$full_path/smaps
    debug_echo $smaps_full_path

    heap_begin=false
    while read line
    do
        if [[ $heap_begin == true ]]
        then
            # 本段结束
            if [[ "$line" =~ ^[0-9a-f] ]]
            then
                debug_echo "--------------------------------------------------"
                break
            fi
            if [[ "$line" =~ ^Pss ]]
            then
                debug_echo "$line"
                x=`echo $line | awk '{print $2}'`
                debug_echo "PSS " $x
                PSS_SIZE=$[PSS_SIZE+x]
            fi
            if [[ "$line" =~ ^Rss ]]
            then
                debug_echo "$line"
                x=`echo $line | awk '{print $2}'`
                debug_echo "RSS " $x
                RSS_SIZE=$[RSS_SIZE+x]
            fi
            if [[ "$line" =~ ^Private_Dirty ]]
            then
                debug_echo "$line"
                x=`echo $line | awk '{print $2}'`
                debug_echo "Private_Dirty " $x
                PD_SIZE=$[PD_SIZE+x]
            fi
            if [[ "$line" =~ ^Referenced ]]
            then
                debug_echo "$line"
                x=`echo $line | awk '{print $2}'`
                debug_echo "Referenced " $x
                Ref_SIZE=$[Ref_SIZE+x]
            fi
            if [[ "$line" =~ ^Anonymous ]]
            then
                debug_echo "$line"
                x=`echo $line | awk '{print $2}'`
                debug_echo "Anonymous " $x
                Anon_SIZE=$[Anon_SIZE+x]
            fi
            if [[ "$line" =~ ^Locked ]]
            then
                x=`echo $line | awk '{print $2}'`
                debug_echo "Locked " $x
                LOCK_SIZE=$[LOCK_SIZE+x]
            fi
            continue
        fi

        # 本段开始
        if [[ "$line" =~ \[heap\] ]]
        then
            debug_echo "$line"
            heap_begin=true
        fi
        
    done < $smaps_full_path
    
    # break
done
# PSS_SIZE=0
# RSS_SIZE=0
# PD_SIZE=0
# Ref_SIZE=0
# Anon_SIZE=0
# LOCK_SIZE=0
echo "Total Rss:                  "$RSS_SIZE "KB"
echo "Total Pss:                  "$PSS_SIZE "KB"
echo "Total Private_Dirty:        "$PD_SIZE "KB"
echo "Total Referenced:           "$Ref_SIZE "KB"
echo "Total Anonymous:            "$Anon_SIZE "KB"
echo "Total Locked:               "$LOCK_SIZE "KB"