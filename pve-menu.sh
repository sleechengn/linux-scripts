#!/usr/bin/env bash

# 1. 加载虚拟机列表
MENU_OPTIONS=()
while read -r vmid vmname vmstatus; do
        MENU_OPTIONS+=("$vmid" "$vmname($vmstatus)")
done < <( qm list|sed 1d|awk '{print $1,$2,$3}')

# 2. 检查数组是否为空
if [ ${#MENU_OPTIONS[@]} -eq 0 ]; then
    dialog --msgbox "notfounddat" 8 40
    exit 1
fi

# 3. 传入数组，动态展现菜单
# "${MENU_OPTIONS[@]}" 会将数组元素逐个安全展开
CHOICE=$(dialog --clear \
                --title "Virtual Machine List" \
                --menu "Please select which to run" 18 50 8 \
                "${MENU_OPTIONS[@]}" 2>&1 >/dev/tty)

# 4. 处理用户选择
clear
if [ -n "$CHOICE" ]; then
    echo "you select: $CHOICE"
    qm start $CHOICE
else
    echo "bye"
fi
