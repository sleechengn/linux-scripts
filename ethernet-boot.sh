#!/usr/bin/env bash

if [ "$(ip a|grep enp4s0)" ] && [ "$(which ethtool)" ]; then
        ip link set enp4s0 up
        if [ "$(ethtool enp4s0|grep Link|grep detected|grep yes)" ]; then
                echo "enp4s0 activate"
                dhclient enp4s0 > /dev/null 2>&1 &
        fi
fi