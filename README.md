## 一些脚本，可能没用




### archlinux证书导入（crt)
```
./arch-import-ca.sh <证书文件路径>
```


### archlinux安装gnome桌面环境，在tty里安装配置gnome，自动安装脚本
```
./archlinux-setup-gnome.sh
```


### archlinux自动安装niri桌面环境
```
# install
./archlinux-setup-niri.sh
# 运行
niri-session
```

### archlinux ttyd自动安装
```
./archlinux-setup-web-tty.sh
# 访问 http://ip:8080/ttyd/?disableLeaveAlert=true
```

### archlinux系统安装
```
# 用archlinux iso引导，使用wget等下载脚本到临时目录执行安装
./archlinux-setup.sh
```

### archlinux开机自动登录tty，免于手动输入账号和密钥
```
# root自动登录
./archlinux-shell-auto-login.sh
# 其它用户（先添加用户，必须要存在，并能正常登录）
./archlinux-shell-auto-login.sh <user>
```

### debian证书导入（crt)
```
./deb-import-ca.sh <证书文件>
```

### debian安装docker
```
./debian-setup-docker.sh
```

### debian安装ttyd
```
./debian-setup-web-tty.sh
# 访问 http://ip:8080/ttyd/?disableLeaveAlert=true
```

### debian自动tty登录
```
# root自动登录
./debian-shell-auto-login.sh
# 其它用户（必须存在、可登录）
./debian-shell-auto-login.sh [用户]
```

### 用IP命令删除ipv6地址，所有的
```
./drop-ip6.sh
```

### enx命令开头网卡自动配置IP地址（是一个不断检测不退出的脚本）
```
./enx-nic-auto-dhcp.sh
```

### 自动登录以太网卡
```
./ethernet-boot.sh [网卡名]
# 如果不指定，使用enp4s0为网卡名
```

### 自签证书，后面跟IP地址，生成证书
```
# 生成CA证书，服务器证书，中间证书
./genssl.sh <IPADDR> # 指定服务器地址信息生成
./genssl.sh # 手动交互式设置IP生成
```

### 生成wifi连接信息
```
# 在/etc/network/interfaces.d 生成wifi连接配置
./genwifi.sh <ssid> <passwd>
```

### 交互式配置接口的IP地址
```
./ip-manage.sh
```

### 控制台播放mpv(mpv必须存在)
```
./play-mpv.sh
```

### 未实现，关机
```
./powerdown.sh
```

### docker镜像重命名推本地注册表(192.168.13.73:5000)
```
./push2local.sh <repo/img:tag>
```

### 编辑pve虚拟机和容器(lxc)配置文件
```
./pve-edit.sh
```

### pve选则当前虚拟机启动
```
./pve-menu.sh
```

### 使用rest启动虚拟机
```
# 注意修改 密码或配置环境变量 为pve root密码
./pve-start.sh <虚拟机id>
```

### 快捷配置核显直通（只适用于我的机器）你要使用自己修改
```
./pve-uhd-passthrough-set.sh <vmid>
```

### qcow2压缩
```
./qcow2compress.sh <源> <目标>
```

### qcow2转vhd
```
./qcow2vpc.sh <源> <目标>
```

### qcow2转固定大小vhd
```
./qcow2vpcfixed.sh <源> <目标>
```

### raw转qcow2
```
./raw2qcow2.sh <源> <目标>
```

### raw转vhd
```
./raw2vpc.sh <src> <dst>
```

### 删除本地仓库镜像（只适用于我的）你要使用自己修改
```
./remove-image.sh <repo/img>
```

### tty显示图片(文件：/root/.bg.jpg)(可自己修改)路径
```
./show-image.sh
```