#!/usr/bin/env bash
set -e
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
    if [ "$(realpath $(pwd))" == / ]; then
        while IFS= read line; do 
            FILE_LIST+=("$line" "$(echo $line|awk -F / '{print $NF}')")
        done < <(find $(realpath $(pwd)) -maxdepth 2|grep -F ".mp4")
    else
        while IFS= read line; do 
            FILE_LIST+=("$line" "$(echo $line|awk -F / '{print $NF}')")
        done < <(find $(realpath $(pwd))/ -maxdepth 2|grep -F ".mp4")
    fi
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
            if [ -e "" ]; then
                mpv --vo=drm $FILE
            else
                mpv --vo=tct $FILE
            fi
        else
            echo "you cancel"
            exit 1
        fi
    fi

fi