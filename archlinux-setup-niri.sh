#!/usr/bin/env bash
set -xe
if ! command -v dialog > /dev/null 2>&1; then
    pacman -Sy --noconfirm dialog
fi

USERNAME=$(dialog --title "setup user" \
                   --inputbox "username:" 8 45 "" \
                   3>&1 1>&2 2>&3)
ERR=$?
if [ $ERR -eq 0 ] && [ "$USERNAME" ]; then
    if ! id $USERNAME > /dev/null 2>&1; then
        PASSWORD=$(dialog --title "setup user" \
                   --inputbox "password:" 8 45 "" \
                   3>&1 1>&2 2>&3)
        ERR=$?
        if [ $ERR -eq 0 ] && [ "$PASSWORD" ]; then
            useradd -m $USERNAME
            echo "$USERNAME:$PASSWORD"|chpasswd
        else
            echo "password not set"
            exit 1
        fi
    else
        echo user: $USERNAME exist
    fi
else
    echo username err
    exit 1
fi


pacman -S --noconfirm niri mako ghostty swaybg waybar xwayland-satellite
pacman -S --noconfirm alacritty fuzzel pcmanfm-qt
usermod -aG video,tty,input $USERNAME
pacman -S --noconfirm flatpak
flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
flatpak install -y --noninteractive flathub com.microsoft.Edge

pacman -Sy --noconfirm noto-fonts-cjk adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts wqy-zenhei
pacman -Sy --noconfirm fcitx5 fcitx5-chinese-addons fcitx5-configtool fcitx5-gtk fcitx5-qt
cat >> /etc/environment <<EOF
GTK_IM_MODULE=fcitx5
QT_IM_MODULE=fcitx5
XMODIFIERS=@im=fcitx5
EOF

pacman -S --noconfirm pipewire pipewire-pulse wireplumber pavucontrol
systemctl --user -M $USERNAME@ daemon-reload
su $USERNAME -c 'gsettings set org.gnome.desktop.interface color-scheme prefer-dark'
systemctl --user -M $USERNAME@ enable --now pipewire pipewire-pulse wireplumber