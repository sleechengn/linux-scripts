## 一些脚本，可能没用

自动登录root，开机自动登录
```
./debian-auto-login-tty.sh
```


enx的网卡自动获取dhcp，注意这个是一个长期进程，不会返回
```
./enx-dhcp.sh
```


生成wifi连接配置，重启后生效
```
./genwifi.sh SSID PASSWORD
```


自动tmux配置，使用t命令进入tmux
```
tmux.sh
```


自签证书，后面跟IP地址，生成证书
```
genssl.sh <IPADDR>
```


删除docker镜像
```
remove-image.sh <REPO/IMG:TAG>
```

拔掉USB执行指定命令
```
./usb-detect-reboot.sh <usbid eg. 248d:5b5e>
```