#!/usr/bin/env bash
while IFS= read -r ifn; do
    echo $ifn
    ip address show $ifn|grep inet6|awk '{print $2}'|xargs -i ip add del {} dev $ifn
done < <(ip a|grep "^[0-9]\\:[ ]*.*"|awk '{print $2}'|awk -F : '{print $1}')
clear
ip a
ech "complete"