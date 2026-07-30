#!/usr/bin/env bash
set -e
pacman -Sy --noconfirm gdm gnome-tweaks gnome-control-center \
    gnome sudo man-db man-pages
systemctl enable gdm
if [ ! -e "/home/sa" ]; then
    useradd -m sa
    echo "sa:123456"|chpasswd
fi
systemctl set-default graphical.target
pacman -Sy --noconfirm gnome-browser-connector extension-manager

if [ ! "$(cat /etc/gdm/custom.conf|grep AutomaticLogin)" ]; then
    sed -i '/\[daemon\]/a\AutomaticLogin=sa' /etc/gdm/custom.conf
    sed -i '/\[daemon\]/a\AutomaticLoginEnable=True' /etc/gdm/custom.conf
fi

pacman -Sy --noconfirm fcitx5 fcitx5-chinese-addons fcitx5-configtool fcitx5-gtk fcitx5-qt
cat >> /etc/environment <<EOF
GTK_IM_MODULE=fcitx5
QT_IM_MODULE=fcitx5
XMODIFIERS=@im=fcitx5
EOF

sed -i 's/.*zh_CN.UTF-8 UTF-8.*/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

pacman -Sy --noconfirm noto-fonts-cjk adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts wqy-zenhei
pacman -Sy --noconfirm flatpak

flatpak install -y --noninteractive flathub com.microsoft.Edge
pacman -Sy --noconfirm ghostty