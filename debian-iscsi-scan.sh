#!/usr/bin/env bash

set -x

if [ ! "$(dpkg -l | grep -F 'open-iscsi')" ]; then
    apt install -y open-iscsi
    systemctl enable --now iscsid
    systemctl enable --now open-iscsi
fi

if ! command -v dialog > /dev/null 2>&1; then
    apt install -y dialog
fi

if [ ! "$1" ]; then
    echo "./debian-iscsi-scan.sh <ip>"
    exit 1
fi

OPTIONS=()
while IFS= read -r line; do
    echo $line
    OPTIONS+=("$line" "")
done < <(iscsiadm -m discovery -t sendtargets -p $1)

if [ ${#OPTIONS[@]} -eq 0 ]; then
    dialog --msgbox "not found" 8 40
    exit 1
fi

OPTION=$(dialog --clear \
                    --title "device" \
                    --menu "Please select which" 18 99 8 \
                    "${OPTIONS[@]}" 4>&1 1>&2 2>&4 4>&-)
ERR=$?
if [ $ERR -eq 0 ] && [ "$OPTION" ]; then
    TARGET=$(echo $OPTION|awk '{print $2}')
    PORT=$(echo $OPTION|awk '{print $1}'|awk -F "," '{print $1}')
    LUN=$(echo $OPTION|awk '{print $1}'|awk -F "," '{print $2}')
    echo $TARGET $PORT $LUN
    iscsiadm -m node -T $TARGET -p $PORT --login
    iscsiadm -m node -T $TARGET -p $PORT -o update -n node.startup -v automatic
else
    exit 1
fi