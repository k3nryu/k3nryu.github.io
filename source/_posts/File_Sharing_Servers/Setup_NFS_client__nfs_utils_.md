---
title: Setup NFS client (nfs-utils)
date: 2021/05/11 15:01:24
categories:
  - File Sharing Servers
toc: true
#sidebar: none
---

nfs客户端通过mount实现连接服务器

下载安装nfs-utils
```shell
yum install nfs-utils
```

确认
```shell
[root@client ~]# showmount -e 192.168.64.48
Export list for 192.168.64.48:
/tmp/nfs 192.168.64.0/22
```

挂载锚点
```shell
mount -t nfs 192.168.64.48:/tmp/nfs /mnt

df -hT
```

## Automatically mount by using **autofs**
> One drawback of using /etc/fstab is that, regardless of how infrequently a user accesses the NFS mounted file system, the system must dedicate resources to keep the mounted file system in place. This is not a problem with one or two mounts, but when the system is maintaining mounts to many systems at one time, overall system performance can be affected.
> https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/storage_administration_guide/nfs-autofs

Step1. Install **autofs**
```
dnf -y install autofs
systemctl enable autofs
```
Step2. Edit auto.master for direct mapping
```
vim /etc/auto.master
#/misc /etc/auto.misc
/- /etc/auto.misc
```
Step3. Edit auto.misc
```
vim /etc/auto.misc
/share -fstype=nfs4,rw 192.168.65.129:/share
```
Step4. Restart autofs to apply the changes
```
systemctl restart autofs
