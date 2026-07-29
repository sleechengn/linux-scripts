#!/usr/bin/env bash

if command -v apt > /dev/null 2>&1; then
    if ! command -v mpv > /dev/null 2>&1; then
        apt install -y mpv
    fi

    if ! command -v dialog > /dev/null 2>&1; then
        apt install -y dialog
    fi
fi

if command -v mpv > /dev/null 2>&1; then

    FILE_LIST=()
    while IFS= read line; do 
        FILE_LIST+=("$line" "$(echo $line|awk -F / '{print $NF}')")
    done < <(find $(realpath $(pwd))/|grep -F ".mp4")
    if [ ${#FILE_LIST[@]} -eq 0 ]; then
        echo "no files"
        exit 1
    else
        FILE=$(dialog --clear \
            --title "File Selector" \
            --menu "Please select MP4 File:" \
            20 80 10 \
            "${FILE_LIST[@]}" \
            3>&1 1>&2 2>&3 3>&-)
        clear
        ERR=$?
        if [ $ERR -eq 0 ] && [ "$FILE" ]; then
            mpv --vo=drm $FILE
        else
            echo "you cancel"
            exit 1
        fi
    fi

fi