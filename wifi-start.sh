#!/usr/bin/env bash

ip link set wlp3s0 up
#wpa_cli -i wlp3s0 disconnect
#iw dev wlp3s0 disconnect
SSID=$(iw wlp3s0 scan|grep SYJD|grep 8306|awk '{print $2}')
echo "SSID=$SSID"

if [ "$SSID" ]; then
        wpa_passphrase $SSID 88888888 > /tmp/wpa_supplicant.conf
        wpa_supplicant -B -i wlp3s0 -c /tmp/wpa_supplicant.conf

        SETTING_LOOP=1
        while [ $SETTING_LOOP -eq 1 ]; do
                if [ "$(iw dev wlp3s0 link|grep SSID)" ]; then
                        echo "connected"
                        dhclient wlp3s0
                        SETTING_LOOP=0
                else
                        sleep 1
                fi
        done
fi