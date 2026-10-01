#!/usr/bin/env bash
set -xe

if [ "$1" ]; then
    if [ "$2" ]; then
        SRC=$1
        DST=$2
        if [ -e "$SRC" ] && [ -d "$DST" ]; then
            BASEFILENAME=$(basename $SRC)
        else
            if [ ! -e "$SRC" ]; then echo "$SRC not exist"; fi
            if [ ! -d "$DST" ]; then echo "$DST not available"; fi
            exit 1
        fi
    else
        for file in $(pwd)/*; do
            echo "current file $file"
            echo "basename $(basename $file)"
            BASEFILENAME=$(basename $file)
            DST=$1
            if [ ! -d "$DST" ]; then
                echo "$DST not available"
                exit 1
            fi
            FINDCN=$(find $DST/|grep -F "$BASEFILENAME"|wc -l)
            if [ $FINDCN -eq 1 ]; then
                TGT=$(find $DST/|grep -F "$BASEFILENAME")
                rm -rf $file
                ln $TGT $(pwd)
            else
                echo "find $FINDCN"
                exit 1
            fi
        done
    fi
else
    echo "not found target"
fi