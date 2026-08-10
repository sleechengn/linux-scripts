#!/usr/bin/bash

#VM ID
VMID=$1

#认证密码
AUTH_PASSWORD="${PVE_PASSWD:-123456}"

#通过账号密码获取票据和凭证
auth_json=$(curl --silent --insecure --data "username=root@pam&password=$AUTH_PASSWORD"  https://localhost:8006/api2/json/access/ticket)
#提取JSON中的票据
ticket=$(echo $auth_json | jq --raw-output '.data.ticket')
#提取JSON中的凭证
csrf_token=$(echo $auth_json | jq --raw-output '.data.CSRFPreventionToken')

#用curl通过票据和凭证调用开机api
curl -k -v -X POST -b "PVEAuthCookie=$ticket" -H "CSRFPreventionToken: $csrf_token" https://localhost:8006/api2/json/nodes/pve/qemu/$VMID/status/start