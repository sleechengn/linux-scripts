#!/usr/bin/env bash

if [ "$1" ]; then
        VMID=$1
        EVDEV_MOUSE=$(find /dev/input/by-path|grep usb|grep event-mouse|head -n 1)
        if [ ! "$EVDEV_MOUSE" ]; then
                echo "dowgrade mouse"
                EVDEV_MOUSE=$(find /dev/input/by-path|grep event-mouse|head -n 1)
        fi
        EVDEV_KBD=$(find /dev/input/by-path|grep event-kbd|grep -v usb|head -n 1)
        if [ ! "$EVDEV_KBD" ]; then
            echo "downgrade kb"
            EVDEV_KBD=$(find /dev/input/by-path|grep event-kbd|head -n 1)
        fi
        echo "keyboard mouse usage:"
        echo kbd=$EVDEV_KBD
        echo mouse=$EVDEV_MOUSE
        echo "set vm $VMID"
        qm set $VMID --args "-acpitable file=/opt/vm/ssdt-battery.aml -set device.hostpci0.bus=pcie.0 -set device.hostpci0.addr=0x02.0 -set device.hostpci0.x-igd-gms=0x2 -set device.hostpci0.x-igd-opregion=on -set device.hostpci0.x-igd-lpc=on -object input-linux,id=kbd,evdev=$EVDEV_KBD,grab_all=on,repeat=on -object input-linux,id=mouse1,evdev=$EVDEV_MOUSE,grab_all=on"
        qm set $VMID -hostpci0 0000:00:02.0,pcie=1,romfile=vbios/fx50gd.rom,x-vga=1
        qm set $VMID -hostpci1 0000:00:1f.3,pcie=1
        qm set $VMID -vga none
        qm set $VMID -hookscript pvevm-hooks-uhd:snippets/pvevm-hooks-uhd.sh
        qm set $VMID -tablet 0
        echo "请注意：已经设置了大部分参数，但是romfile，evdev需要修改，配合pvevm-hooks-uhd使用"
else
        echo "usage ./pve-uhd-passthrought-set.sh vmid"
fi