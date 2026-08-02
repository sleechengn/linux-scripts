#!/usr/bin/env bash


if [ "$1" ]; then
    if [ $(id -u $(whoami)) -eq 0 ]; then
        cp $1 /etc/ca-certificates/trust-source/anchors/
        trust extract-compat
    else
        sudo cp $1 /etc/ca-certificates/trust-source/anchors/
        sudo trust extract-compat
    fi
    
else
    echo "usage: ./arch-import-ca.sh [path/to/crt]"
fi