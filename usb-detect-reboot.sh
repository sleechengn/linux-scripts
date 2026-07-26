#!/usr/bin/env bash
USBID=$1

if [ ! "$USBID" ]; then
    echo "please input usb id eg. 248d:5b5e"
else

if [ "$USBID" == "-r" ]; then
    systemctl stop udr
    systemctl disable udr
    ps -ef|grep udr.sh|awk '{print $2}'|xargs -i kill -9 {}
else

mkdir -p /opt/udr
if [ ! -e "/opt/udr/udr.sh" ]; then
cat > /opt/udr/udr.sh <<EOF
#!/usr/bin/env bash
KEEP="true"
while [ \$KEEP == "true" ]; do
    if [ "\$(lsusb|grep -F '$USBID')" ]; then
        echo "usb detected, keep"
    else
        qm list |grep running|awk '{print \$1}'|grep -v 101|grep -v 103|xargs -i qm stop {}
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

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now udr
fi

fi
fi