#!/usr/bin/env bash

apt install iw isc-dhcp-client wpasupplicant iptables -y

SSID=$1
PWD=$2

PSK=$(wpa_passphrase $1 $2|grep [^#]psk=.*|awk -F '=' '{print $2}')
echo $PSK
IFNAME=$(iw dev|grep Interface|awk '{print $2}')
cat > /etc/network/interfaces.d/wifi.conf <<EOF
auto $IFNAME
iface $IFNAME inet dhcp
        wpa-ssid $SSID
        wpa-psk $PSK
        post-up iptables -t nat -A POSTROUTING -j MASQUERADE
        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-down iptables -t nat -D POSTROUTING -j MASQUERADE
EOF