#!/usr/bin/env bash

if command -v which > /dev/null 2>&1; then
    if command -v apt > /dev/null 2>&1; then
        apt install iw isc-dhcp-client wpasupplicant iptables dialog -y
    fi
    if command -v pacman > /dev/null 2>&1; then
        pacman -S --noconfirm iw dialog dhclient wpa_supplicant iptables
    fi
else
    echo "which not install"
    exit 1
fi
IFNAME=$(iw dev|grep Interface|head -n 1|awk '{print $2}')
NAME=""
if [ ! "$1" ]; then
    NAME=$(dialog --title "wifi ssid" \
                   --inputbox "ssid:" 8 40 "" \
                   3>&1 1>&2 2>&3)
    echo "wifi name: $NAME"
    if [ ! "$NAME" ]; then

        killall -9 wpa_supplicant

        ssids=()
        ip link set $IFNAME up
        while IFS= read -r li; do
            ssids+=("$li" "$li")
        done < <(iw $IFNAME scan|grep SSID|awk '{print $2}')

        CHOICE=$(dialog --clear \
                    --title "Virtual Machine List" \
                    --menu "Please select which to run" 18 99 8 \
                    "${ssids[@]}" 2>&1 >/dev/tty)
        ERR=$?
        echo "selected $CHOICE"
        if [ $ERR -eq 0 ] && [ "$CHOICE" ]; then
            NAME=$CHOICE
        else
            echo "please input ssid"
            exit 1
        fi
    fi
else
    NAME=$1
fi

PASSWD=""
if [ ! "$2" ]; then
    PASSWD=$(dialog --title "passwd" \
                   --inputbox "passwd:" 8 45 "" \
                   3>&1 1>&2 2>&3)
    echo "wifi passwd: $PASSWD"
    if [ ! "$PASSWD" ]; then
    echo "please input pwd"
    exit 1
    fi
else
    PASSWD=$2
fi

echo "./wifi-start.sh SSID PASSWORD"

echo "info -----------------------------------"
echo "ssid $NAME"
echo "password $PASSWD"

ip link set $IFNAME up
#killall -9 wpa_supplicant
#wpa_cli -i $IFNAME disconnect
#iw dev $IFNAME disconnect

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