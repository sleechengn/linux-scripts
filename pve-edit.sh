#!/usr/bin/env bash
MENU_OPTIONS=()
if [ "$(ls -A /etc/pve/qemu-server/)" ]; then
    for file in /etc/pve/qemu-server/*; 
    do
        echo $file
        MENU_OPTIONS+=("$file" "$(cat $file|grep name|awk '{print $2}')")
    done
fi
if [ "$(ls -A /etc/pve/lxc/)" ]; then
    for file in /etc/pve/lxc/*; 
    do
        echo $file
        MENU_OPTIONS+=("$file" "$(cat $file|grep hostname|awk '{print $2}')")
    done
fi
if [ ${#MENU_OPTIONS[@]} -eq 0 ]; then
    dialog --msgbox "notfound" 8 40
    exit 1
fi
CHOICE=$(dialog --clear \
            --title "Virtual Machine List" \
            --menu "Please select which" 18 60 8 \
            "${MENU_OPTIONS[@]}" 2>&1 >/dev/tty)
if [ $? -eq 0 ]; then
    nano $CHOICE
fi