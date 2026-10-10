#!/usr/bin/env bash

if ! command -v ffmpeg > /dev/null 2>&1; then
        if command -v apt > /dev/null 2>&1; then
                apt update
                apt install -y ffmpeg
        fi
fi

if [ "$1" ] && [ "$2" ] && [ "$3" ] && [ "$4" ]; then
    ffmpeg -ss $1 -to $2 -accurate_seek -i $3 -c:a mp3 -c:v h264 -crf 18 -f mp4 $4
else
    echo "参数错误"
    echo <start> <end> <file> <file>
fi