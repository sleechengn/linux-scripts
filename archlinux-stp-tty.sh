#!/usr/bin/env bash
pacman -S --noconfirm psmisc curl aria2 fish
mkdir -p /opt/ttyd
cd /opt/ttyd
DOWNLOAD=$(curl -s https://api.github.com/repos/tsl0922/ttyd/releases/latest | grep browser_download_url |grep ttyd.x86_64| cut -d'"' -f4)
aria2c -j 10 -x 10 -k 1m "$DOWNLOAD" -o "ttyd.x86_64"
chmod +x ttyd.x86_64
ln -s $(pwd)/ttyd.x86_64 /usr/bin/ttyd.x86_64

cat > /etc/systemd/system/ttyd.service << EOF
[Unit]
Description=ttyd
After=network.target

[Service]
ExecStart=/opt/ttyd/ttyd.x86_64 -W --port 8080 --base-path /ttyd -t enableZmodem=true -t enableTrzsz=true --cwd ~ /usr/bin/fish

User=root
Type=simple

[Install]
WantedBy=multi-user.target
EOF

systemctl enable ttyd
systemctl start ttyd
#如果没有启动，再执行
killall -9 ttyd.x86_64
systemctl start ttyd