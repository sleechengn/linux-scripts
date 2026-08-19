#!/usr/bin/env bash

set -ex

DISK_NAME=$1
if [ ! "$DISK_NAME" ]; then
    echo "input disk, lsblk view, eg. vda sda nvme*"

    if ! command -v dialog > /dev/null 2>&1; then
        pacman -Sy --noconfirm dialog
    fi

    OPTIONS=()
    while IFS= read -r line; do
        OPTIONS+=("$(echo $line|awk '{print $1}')" "$line")
    done < <(lsblk|sed '1d')

    SELECT=$(dialog --clear \
            --title "disk Selector" \
            --menu "Please select disk:" \
            20 80 10 \
            "${OPTIONS[@]}" \
            3>&1 1>&2 2>&3 3>&-)
    ERR=$?
    echo "$ERR,$SELECT"
    if [ $ERR -eq 0 ] && [ "$SELECT" ]; then
        DISK_NAME=$SELECT
    else
        exit 0
    fi
fi
DISK="/dev/${DISK_NAME}"
echo "disk: ${DISK}"
# 1.  guid partition table
sudo parted --script "${DISK}" mklabel gpt

# 2. create 1GB EFI partition (from 1MiB 4K align）
sudo parted --script "${DISK}" mkpart primary fat32 1MiB 1025MiB
sudo parted --script "${DISK}" set 1 esp on

# 3. create ext4 partition
sudo parted --script "${DISK}" mkpart primary ext4 1025MiB 100%

# 4. refresh
sudo partprobe "${DISK}"
sleep 2

# 5. nvme p1/p2
if [[ "${DISK_NAME}" == nvme* ]]; then
    PART1="${DISK}p1"
    PART2="${DISK}p2"
else
    PART1="${DISK}1"
    PART2="${DISK}2"
fi

# 6. format
echo "format EFI: ${PART1}"
sudo mkfs.vfat -F 32 "${PART1}"

echo "format ext4: ${PART2}"
sudo mkfs.ext4 -F "${PART2}"

echo "comp"

mount ${PART2} /mnt
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
mkdir -p /mnt/boot/efi
mount ${PART1} /mnt/boot/efi

ROOT_PASSWORD=$(dialog --title "setting root password" \
                   --inputbox "input root password:" 8 45 "" \
                   3>&1 1>&2 2>&3)
ERR=$?
if [ $ERR -eq 0 ] && [ "$ROOT_PASSWORD" ]; then
    echo "root password:$ROOT_PASSWORD"
else
    echo "root password error"
    exit 1
fi
USERNAME=$(dialog --title "setting user name" \
                   --inputbox "input username:" 8 45 "" \
                   3>&1 1>&2 2>&3)
ERR=$?
if [ $ERR -eq 0 ] && [ "$USERNAME" ]; then
    echo "username:$USERNAME"
else
    echo "user error"
    exit 1
fi
PASSWORD=$(dialog --title "setting user $USERNAME password" \
                   --inputbox "input $USERNAME password:" 8 45 "" \
                   3>&1 1>&2 2>&3)
ERR=$?
if [ $ERR -eq 0 ] && [ "$PASSWORD" ]; then
    echo "$USERNAME password:$PASSWORD"
else
    echo "$USERNAME password error"
    exit 1
fi
arch-chroot /mnt /usr/bin/bash <<EOF
pacman -Sy --noconfirm grub efibootmgr os-prober openssh sudo fish networkmanager
systemctl enable sshd
grub-install ${DISK} --removable
echo "root:$ROOT_PASSWORD"|chpasswd
useradd -s /usr/bin/fish -m $USERNAME
echo "$USERNAME:$PASSWORD"|chpasswd
grub-mkconfig -o /boot/grub/grub.cfg
ln -sf /usr/share/zoneinfo/Area/Location /etc/localtime
systemctl enable NetworkManager
find /usr/lib/|grep -F /getty@|xargs -i sed -i "s,^ExecStart.*,ExecStart=-/sbin/agetty --noclear %I $TERM --autologin $USERNAME,g" {}
systemctl daemon-reload
systemctl disable getty@tty1.service
systemctl enable getty@tty1.service
EOF

if [ -e "/mnt/etc/sudoers" ]; then
    if [ ! "$(cat /mnt/etc/sudoers|grep -F $USERNAME|grep -F 'ALL=(ALL:ALL)')" ]; then
        sed -i "/.*root[ ]*ALL=(ALL:ALL)[ ]*ALL.*/a $USERNAME      ALL=(ALL:ALL) NOPASSWD:ALL" /mnt/etc/sudoers
    fi
fi

echo "please reboot"