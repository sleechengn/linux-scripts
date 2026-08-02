#!/usr/bin/env bash


if [ "$1" ]; then
    if [ $(id -u $(whoami)) -eq 0 ]; then
        cp $1 /usr/local/share/ca-certificates/
        update-ca-certificates
    else
        sudo cp $1 /usr/local/share/ca-certificates/
        sudo update-ca-certificates
    fi
    
else
    echo "usage: ./deb-import-ca.sh [path/to/crt]"
fi