## 一些脚本，可能没用

### 开机自动登录tty，免于手动输入账号和密钥
```
# root自动登录
./archlinux-shell-auto-login.sh
# 其它用户（先添加用户，必须要存在，并能正常登录）
./archlinux-shell-auto-login.sh <user>
```


### 导入archlinux证书（crt)
```
./arch-import-ca.sh <证书文件路径>
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
#删除服务
./usb-detect-reboot.sh -r
```