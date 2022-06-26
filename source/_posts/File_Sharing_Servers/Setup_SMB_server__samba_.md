---
title: Setup SMB server (samba)
date: 2021/05/10 17:16:45
categories:
  - File Sharing Servers
toc: true
#sidebar: none
---

Socket Statisticsの確認
```shell
[root@localhost html]# ss -ntul
Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port
tcp LISTEN 0 128 0.0.0.0:22 0.0.0.0:*
tcp LISTEN 0 128 [::]:22 [::]:*
```
smb serverをインストール、FWの設定
```shell
yum install samba
firewall-cmd --zone=public --add-service=samba --permanent
firewall-cmd --reload
[root@localhost ~]# firewall-cmd --list-all
public (active)
target: default
icmp-block-inversion: no
interfaces: enp0s3
sources:
services: cockpit dhcpv6-client ftp http samba ssh
ports:
protocols:
masquerade: no
forward-ports:
source-ports:
icmp-blocks:
rich rules:
```
修改配置文件
```shell
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak t#备份配置文件
vim /etc/samba/smb.conftttt#编辑内容
```
vim编辑里面修改或者添加以下内容
```shell
#修改global全局配置
#samba4较之前的samba3有一个重大的变化是：security不再支持share
[global]
workgroup = WORKGROUP
security=user
map to guest =Bad User
tt
#添加名为share的共享文件夹
[share]
comment = share all
path = /tmp/samba
browseable = yes
public = yes
writable = yes
create mode = 0755
force create mode = 0755
directory mode = 0755
force directory mode = 0755
force user = apache

```
检测语法是否错误
```shell
[root@localhost ~]# testparm
Load smb config files from /etc/samba/smb.conf
Loaded services file OK.
Server role: ROLE_STANDALONE

Press enter to see a dump of your service definitions
```
创建一个共享文件夹
```shell
mkdir /tmp/samba
chmod 777 /tmp/samba
touch /tmp/samba/sharefiles
echo "111111" > /tmp/samba/sharefiles
```
启动smb服务
```shell
[root@localhost ~]# systemctl start smb
```

确认smb版本
```
smbstatus --version
```

通过Socket Statistics可以看到139, 445端口已经被打开
```shell
[root@localhost ~]# ss -tunl
Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port
tcp LISTEN 0 50 0.0.0.0:139 0.0.0.0:*
tcp LISTEN 0 128 0.0.0.0:22 0.0.0.0:*
tcp LISTEN 0 50 0.0.0.0:445 0.0.0.0:*
tcp LISTEN 0 50 [::]:139 [::]:*
tcp LISTEN 0 128 [::]:22 [::]:*
tcp LISTEN 0 50 [::]:445 [::]:*
```
此时防火墙是打开的状态
```shell
[root@localhost ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
Active: active (running) since Tue 2021-05-11 09:40:50 JST; 37min ago
Docs: man:firewalld(1)
Main PID: 857 (firewalld)
Tasks: 2 (limit: 12404)
Memory: 36.5M
CGroup: /system.slice/firewalld.service
mq857 /usr/libexec/platform-python -s /usr/sbin/firewalld --nofork --nopid

May 11 09:40:49 localhost.localdomain systemd[1]: Starting firewalld - dynamic firewall daemon...
May 11 09:40:50 localhost.localdomain systemd[1]: Started firewalld - dynamic firewall daemon.
May 11 09:40:51 localhost.localdomain firewalld[857]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option. It w>
```
关于SELinux

```shell
[root@localhost ~]# getenforce
Enforcingttt#强制执行
#这种状态不可访问
```
```shell
[root@localhost ~]# getenforce
Permissivettt#许可的
#这种状态只有只读权限
```
```shell
[root@localhost ~]# vim /etc/selinux/config

#SELINUX=enforcingtt#强制执行
SELINUX=disabledtt#关闭

[root@localhost ~]# reboott#需要重启
[root@localhost ~]# getenforce
disabled
#这种状态只有只读权限
```
在win10下打开服务器地址


```


