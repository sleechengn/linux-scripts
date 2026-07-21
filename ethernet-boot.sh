#!/usr/bin/env bash
IFNAME=enp4s0
if [ "$1" ]; then
        IFNAME="$1"
fi
if [ ! "$(which ethtool)" ]; then
        apt install -y ethtool
fi
if [ "$(ip a|grep $IFNAME)" ] && [ "$(which ethtool)" ]; then
        ip link set $IFNAME up
        if [ "$(ethtool $IFNAME|grep Link|grep detected|grep yes)" ]; then
                echo "$IFNAME activate"
                dhclient $IFNAME > /dev/null 2>&1 &
        fi
else
        echo "not found $IFNAME or ethtool failure"
fi