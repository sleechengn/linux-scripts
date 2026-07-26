#!/usr/bin/env bash

if [ -e "/usr/bin/which" ] || [ -e "/bin/which" ]; then

    if [ "$(which apt)" ]; then
        apt install iw isc-dhcp-client wpasupplicant iptables -y
    fi
    if [ "$(which pacman)" ]; then
        pacman -S --noconfirm iw dhclient wpa_supplicant iptables
    fi

else

    echo "which not install"
    exit 1

fi

echo "usage:"
echo "./wifi-start.sh SSID PASSWORD"

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
#killall -9 wpa_supplicant
#wpa_cli -i $IFNAME disconnect
#iw dev $IFNAME disconnect
killall -9 wpa_supplicant
SSID=$(iw $IFNAME scan|grep -F "$NAME"|awk '{print $2}')
echo "SSID=$SSID"

if [ "$SSID" ]; then
        wpa_passphrase $SSID $PASSWD > /tmp/wpa_supplicant.conf
        wpa_supplicant -B -i $IFNAME -c /tmp/wpa_supplicant.conf

        SETTING_LOOP=1
        TRY_COUNT=0
        while [ $SETTING_LOOP -eq 1 ] && [ $TRY_COUNT -lt 10 ]; do
                TRY_COUNT=$(($TRY_COUNT+1))
                echo "try count $TRY_COUNT"
                if [ "$(iw dev $IFNAME link|grep SSID)" ]; then        
                        echo 1 > /proc/sys/net/ipv4/ip_forward
                        echo "connected"
                        dhclient $IFNAME
                        if [ ! "$(iptables -t nat -nvL --line-numbers|grep MASQUERADE)" ]; then
                            iptables -t nat -A POSTROUTING -j MASQUERADE
                        fi
                        SETTING_LOOP=0
                        exit 0
                else
                        sleep 1
                fi
        done
        echo "try count over"
        killall -9 wpa_supplicant
        exit 1
else
    echo "not found $NAME"
fi