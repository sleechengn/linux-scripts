#!/usr/bin/env bash

mkdir -p /opt/udr
if [ ! -e "/opt/udr/udr.sh" ]; then
cat > /opt/udr/udr.sh <<EOF
#!/usr/bin/env bash
KEEP="true"
while [ \$KEEP == "true" ]; do
    if [ "\$(lsusb|grep -F 248d|grep -F 5b5e)" ]; then
        echo "usb detected, keep"
    else
        qm list |grep running|awk '{print \$1}'|grep -v 101|grep -v 103|xargs -i qm shutdown {}
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