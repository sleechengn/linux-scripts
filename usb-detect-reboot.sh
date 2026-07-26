#!/usr/bin/env bash
set -x
USBID=$1

if [ ! "$USBID" ]; then

    if ! command -v dialog &> /dev/null; then
    apt install -y dialog
        echo "not found dialog (eg. sudo apt install dialog)"
        exit 1
    fi
    if ! command -v lsusb &> /dev/null; then
    apt install -y usbutils
        echo "not found usbutils (eg. sudo apt install usbutils)"
        exit 1
    fi

    MENU_OPTIONS=()
    while IFS= read -r line; do
        echo $line
        usb_id=$(echo "$line" | grep -oP 'ID [0-9a-fA-F]{4}:[0-9a-fA-F]{4}' | awk '{print $2}')
        echo $usb_id
        if [ ! -z "$usb_id" ]; then
            MENU_OPTIONS+=("$usb_id" "$line")
        fi
    done < <(lsusb)

    if [ ${#MENU_OPTIONS[@]} -eq 0 ]; then
        dialog --title "alter" --msgbox "not found USB device" 6 40
        exit 1
    fi

    TMP_FILE=$(mktemp)
    dialog --clear \
       --title "USB Selector" \
       --menu "Please select USB device (Use up down Enter):" \
       20 80 10 \
       "${MENU_OPTIONS[@]}" 2> "$TMP_FILE"
    if [ $? -eq 0 ]; then
        USBID=$(cat $TMP_FILE|head -n 1)
        echo select $USBID
    else
        exit 1
    fi
fi

if [ "$USBID" == "-r" ]; then
    systemctl stop udr
    systemctl disable udr
    rm -rf /etc/systemd/system/udr.service
    ps -ef|grep udr.sh|awk '{print $2}'|xargs -i kill -9 {}
    rm -rf /opt/udr/udr.sh
else

USER_INPUT=$(dialog --title "command input" \
                    --inputbox "input command to execute" 10 60 "reboot -f" \
                    3>&1 1>&2 2>&3)
if [ ! $? -eq 0 ]; then
    exit 1
fi
echo $USER_INPUT
mkdir -p /opt/udr
if [ ! -e "/opt/udr/udr.sh" ]; then
cat > /opt/udr/udr.sh <<EOF
#!/usr/bin/env bash
KEEP="true"
while [ \$KEEP == "true" ]; do
    if [ "\$(lsusb|grep -F '$USBID')" ]; then
        echo "usb detected, keep"
    else
        $USER_INPUT
        KEEP="false"
    fi
    sleep 3
done
EOF
chmod +x /opt/udr/udr.sh
fi

if [ ! -e "/etc/systemd/system/udr.service" ]; then
cat > /etc/systemd/system/udr.service <<EOF
[Unit]
Description=USB detect reboot
After=network.target

[Service]
ExecStart=/opt/udr/udr.sh
WorkingDirectory=/opt/udr
User=root
Type=simple
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now udr
fi

fi