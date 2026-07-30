#!/usr/bin/env bash

set -e
DISK_NAME=$1
if [ ! "$DISK_NAME" ]; then
    echo "input disk, lsblk view, eg. vda sda nvme*"
    exit 0
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

arch-chroot /mnt /usr/bin/bash <<EOF
pacman -Sy --noconfirm grub efibootmgr os-prober openssh networkmanager
systemctl enable sshd
grub-install ${DISK} --removable
echo "root:123456"|chpasswd
useradd -m sa
echo "sa:123456"|chpasswd
grub-mkconfig -o /boot/grub/grub.cfg
ln -sf /usr/share/zoneinfo/Area/Location /etc/localtime
systemctl enable NetworkManager
EOF