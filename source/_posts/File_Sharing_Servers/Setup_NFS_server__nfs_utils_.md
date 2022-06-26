---
title: Setup NFS server (nfs-utils)
date: 2021/05/11 14:06:04
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
安装nfs-utils
```shell
yum install nfs-utils
```
设置防火墙
```shell
firewall-cmd --zone=public --permanent --add-service={rpc-bind,mountd,nfs}
firewall-cmd --reload
firewall-cmd --list-all
```
设置开机自启
```shell
systemctl enable rpcbind
systemctl enable nfs-server.service
```
设置配置文件
```shell
[root@localhost nfs]# vi /etc/exports
/tmp/nfs/ 192.168.64.0/22(rw,sync,no_root_squash,no_all_squash)
```
配置文件的参数

参数|作用
-|-
ro|只读
rw|读写
root_squash|当NFS客户端以root管理员访问时，映射为NFS服务器的匿名用户
no_root_squash|当NFS客户端以root管理员访问时，映射为NFS服务器的root管理员
all_squash|无论NFS客户端使用什么账户访问，均映射为NFS服务器的匿名用户
sync|同时将数据写入到内存与硬盘中，保证不丢失数据
async|优先将数据写入到内存，然后再写入硬盘；这样效率更高，但可能会丢失数据
anonuid|指定uid的值，此uid必须存在于/etc/passwd中
anongid|指定gid的值

启动nfs服务
```shell
systemctl restart rpcbind nfs-server.service
```

确认
```shell
[root@centos8 mnt]# ss -ntul
Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port
udp UNCONN 0 0 0.0.0.0:111 0.0.0.0:*
udp UNCONN 0 0 [::]:111 [::]:*
tcp LISTEN 0 128 0.0.0.0:111 0.0.0.0:*
tcp LISTEN 0 128 0.0.0.0:22 0.0.0.0:*
tcp LISTEN 0 128 [::]:111 [::]:*
tcp LISTEN 0 128 [::]:22 [::]:*

[root@localhost tmp]# showmount -e localhost
Export list for localhost:
/tmp/nfs 192.168.64.0/22
```
