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

NAME=""
if [ ! "$1" ]; then
    NAME=$(dialog --title "wifi ssid" \
                   --inputbox "ssid:" 8 40 "SYJD-8306" \
                   3>&1 1>&2 2>&3)
    echo "wifi name: $NAME"
    if [ ! "$NAME" ]; then
    echo "please input ssid"
    exit 1
    fi
fi

PASSWD=""
if [ ! "$2" ]; then
    PASSWD=$(dialog --title "passwd" \
                   --inputbox "passwd:" 8 45 "12341234" \
                   3>&1 1>&2 2>&3)
    echo "wifi passwd: $PASSWD"
    if [ ! "$PASSWD" ]; then
    echo "please input pwd"
    exit 1
    fi
fi

echo "./wifi-start.sh SSID PASSWORD"

IFNAME=$(iw dev|grep Interface|head -n 1|awk '{print $2}')

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
                        iw dev $IFNAME link
                        dhclient $IFNAME
                        echo dhclient $?
                        if [ ! "$(ip address|grep -F inet|grep -F $IFNAME)" ]; then
                            echo connect failure
                            exit 1
                        fi
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