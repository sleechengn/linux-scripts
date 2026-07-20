#!/usr/bin/env bash
apt install iw isc-dhcp-client wpasupplicant iptables -y

NAME="SYJD-8306"
if [ "$1" ]; then
    NAME="$1"
fi

PASSWD="88888888"
if [ "$2" ]; then
    PASSWD="$2"
fi

IFNAME=$(iw dev|grep Interface|awk '{print $2}')

echo "info -----------------------------------"
echo "ssid $NAME"
echo "password $PASSWD"

ip link set $IFNAME up
#wpa_cli -i $IFNAME disconnect
#iw dev $IFNAME disconnect
SSID=$(iw $IFNAME scan|grep -F "$NAME"|awk '{print $2}')
echo "SSID=$SSID"

if [ "$SSID" ]; then
        wpa_passphrase $SSID $PASSWD > /tmp/wpa_supplicant.conf
        wpa_supplicant -B -i $IFNAME -c /tmp/wpa_supplicant.conf

        SETTING_LOOP=1
        while [ $SETTING_LOOP -eq 1 ]; do
                if [ "$(iw dev $IFNAME link|grep SSID)" ]; then
                        echo "connected"
                        dhclient $IFNAME
                        SETTING_LOOP=0
                else
                        sleep 1
                fi
        done
else
    echo "not found $NAME"
fi