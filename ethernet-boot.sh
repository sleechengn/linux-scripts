#!/usr/bin/env bash
IFNAME=""
if [ "$1" ]; then
        IFNAME="$1"
else
        if ! command -v dialog > /dev/null 2>&1; then
                if command -v apt > /dev/null 2>&1; then
                        apt install -y dialog
                fi
                if command -v pacman > /dev/null 2>&1; then
                        pacman -S --noconfirm dialog
                fi
        fi
        INTERFACES=()
        while IFS= read -r INTERFACE; do
        INTERFACES+=("$INTERFACE" "")
        done < <(ip a|grep "^[0-9]\\:[ ]*.*"|awk '{print $2}'|awk -F : '{print $1}')

        if [ ${#INTERFACES[@]} -eq 0 ]; then
                dialog --msgbox "not found dev" 8 40
                exit 1
        fi

        IFNAME=$(dialog --clear \
                        --title "devices" \
                        --menu "Please select which" 18 99 8 \
                        "${INTERFACES[@]}" 2>&1 >/dev/tty)
        ERR=$?
        if [ ! $ERR -eq 0 ] || [ ! "$IFNAME" ]; then
                exit 1
        fi
fi
if [ ! "$(which ethtool)" ]; then
        if [ "$(which apt)" ]; then
                apt install -y ethtool
        fi
fi
if [ "$(ip a|grep $IFNAME)" ] && [ "$(which ethtool)" ]; then
        ip link set $IFNAME up
        if [ "$(ethtool $IFNAME|grep Link|grep detected|grep yes)" ]; then
                echo "$IFNAME activate"
                if [ ! "$(ip a|grep -F inet|grep -F $IFNAME)" ]; then
                        dhclient $IFNAME > /dev/null 2>&1 &
                fi
        fi
else
        echo "not found $IFNAME or ethtool failure"
fi