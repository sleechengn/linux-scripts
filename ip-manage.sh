#!/usr/bin/env bash
set -x
if ! command -v dhclient > /dev/null 2>&1; then
    if ! command -v apt > /dev/null 2>&1; then
        apt install -y isc-dhcp-client
    fi
    if ! command -v pacman > /dev/null 2>&1; then
        pacman -Sy --noconfirm dhclient
    fi
fi

if ! command -v dialog > /dev/null 2>&1; then
    if ! command -v apt > /dev/null 2>&1; then
        apt install -y dialog
    fi
    if ! command -v pacman > /dev/null 2>&1; then
        pacman -Sy --noconfirm dialog
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
echo "select:$IFNAME"

MERGES=()
while IFS= read -r ipadd; do
    MERGES+=("$ipadd" "")
done < <(ip address show $IFNAME|grep inet|grep -v inet6|awk '{print $2}')
MERGES+=("AddIPv4" "")
MERGES+=("DHCP" "")
MERGES+=("Exit" "")

OPTION=$(dialog --clear \
                    --title "config" \
                    --menu "Please select which" 18 99 8 \
                    "${MERGES[@]}" 2>&1 >/dev/tty)
ERR=$?
if [ ! $ERR -eq 0 ] || [ ! "$OPTION" ]; then
    exit $ERR
fi
echo "select:$OPTION"

if [ "$OPTION" == "AddIPv4" ]; then
    IPV4=$(dialog --title "ip v4" \
                   --inputbox "ip v4:" 8 45 "" \
                   3>&1 1>&2 2>&3)
    ERR=$?
    echo "select:$IPV4"
    if [ $ERR -eq 0 ] && [ "$IPV4" ]; then
            echo "add new ipv4/cidr address $IPV4"
            ip address add $IPV4 dev $IFNAME
    else
        echo "not found new ip"
        exit $ERR
    fi
else
    if [ "$OPTION" == "Exit" ]; then
        exit 0
    else
        if [ "$OPTION" == "DHCP" ]; then
            echo "dhcp"
            ip link set $IFNAME up
            dhclient $IFNAME
        else
            IPV4="$OPTION"
            echo "select:$OPTION"
            CONFIG_TYPES=()
            CONFIG_TYPES+=("REPLACE" "")
            CONFIG_TYPES+=("DEL" "")
            CONFIG_TYPE=$(dialog --clear \
                        --title "config" \
                        --menu "Please select which" 18 99 8 \
                        "${CONFIG_TYPES[@]}" 2>&1 >/dev/tty)
            ERR=$?
            if [ $ERR -eq 0 ] && [ "$CONFIG_TYPE" ]; then
                echo "select:$CONFIG_TYPE"
                if [ "$CONFIG_TYPE" == "REPLACE" ]; then
                    NEW_IPV4=$(dialog --title "ip v4" \
                        --inputbox "ip v4:" 8 45 "$IPV4" \
                        3>&1 1>&2 2>&3)
                    ERR=$?
                    if [ $ERR -eq 0 ] && [ "$NEW_IPV4" ]; then
                        ip link set $IFNAME up
                        ip address del $IPV4 dev $IFNAME
                        ip address add $NEW_IPV4 dev $IFNAME
                        echo add address $NEW_IPV4 for $IFNAME
                    else
                        exit $ERR
                    fi
                fi
                if [ "$CONFIG_TYPE" == "DEL" ]; then
                    ip link set $IFNAME up
                    ip address del $IPV4 dev $IFNAME
                    echo del $IPV4 from $IFNAME
                fi
            else
                exit $ERR
            fi
        fi
    fi
fi