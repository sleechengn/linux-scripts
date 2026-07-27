#!/usr/bin/env bash

if [ "$(command -v apt)" ]; then
    if [ ! "$(command -v fbi)" ]; then
        apt install -y fbi
    fi
fi

if [ -e "/root/.bg.jpg" ]; then
    fbi /root/.bg.jpg
fi