#!/usr/bin/env bash

if [ "$(command -v apt)" ]; then
    if [ ! "$(command -v fbi)" ]; then
        apt install -y fbi
    fi
    if [ ! "$(command -v chafa)" ]; then
        apt install -y chafa
    fi
fi

if [ -e "/root/.bg.jpg" ]; then
    if [ "$(command -v fbi)" ]; then
        fbi /root/.bg.jpg
        if [ ! $? -eq 0 ]; then
            if [ "$(command -v chafa)" ]; then
                chafa /root/.bg.jpg
            fi
        fi
    else
        if [ "$(command -v chafa)" ]; then
            chafa /root/.bg.jpg
        fi
    fi
fi