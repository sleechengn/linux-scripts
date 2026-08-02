#!/usr/bin/env bash


if [ "$1" ]; then
    cp $1 /usr/local/share/ca-certificates/
    update-ca-certificates
else
    echo "usage: ./deb-import-ca.sh [path/to/crt]
fi