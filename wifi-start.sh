#!/usr/bin/env bash

IFN="wlp3s0"

ip link set $IFN up
#wpa_cli -i $IFN disconnect
#iw dev $IFN disconnect
SSID=$(iw $IFN scan|grep SYJD|grep 8306|awk '{print $2}')
echo "SSID=$SSID"

if [ "$SSID" ]; then
        wpa_passphrase $SSID 88888888 > /tmp/wpa_supplicant.conf
        wpa_supplicant -B -i $IFN -c /tmp/wpa_supplicant.conf

        SETTING_LOOP=1
        while [ $SETTING_LOOP -eq 1 ]; do
                if [ "$(iw dev $IFN link|grep SSID)" ]; then
                        echo "connected"
                        dhclient $IFN
                        SETTING_LOOP=0
                else
                        sleep 1
                fi
        done
fi