#!/usr/bin/env bash
if [ ! "$(which dhclient)" ]; then
        echo "dhclient not found, is not work, you can via fellow command setup"
        echo "apt install -y isc-dhcp-client"
else
        conn="true"
        while [ $conn == "true" ]; do
                enx_nicc=$(ip a|grep ^[0-9]*\:.*enx|awk '{print $2}'|awk -F : '{print $1}')
                if [ "$enx_nicc" ]; then
                        if [ "$(ip a|grep -F $enx_nicc|grep inet)" ]; then
                                echo "已经得到IP地址"
                        else
                                dhclient $enx_nicc
                        fi
                else
                        echo "未插入网卡"
                fi
                sleep 3
        done
fi