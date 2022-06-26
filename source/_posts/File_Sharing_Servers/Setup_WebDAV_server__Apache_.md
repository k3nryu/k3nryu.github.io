---
title: Setup WebDAV server (Apache)
date: 2021/12/15 21:17:52
categories:
  - File Sharing Servers
toc: true
#sidebar: none
---

# Premise
- Installed **Apache** .
- Installed SSL/TLS server **Private key & Certificate**.
- Disabled SELinux.
- Allowed Firewall.

# Enviroment
```
[root@rhel8 ~]# cat /etc/redhat-release
Red Hat Enterprise Linux release 8.5 (Ootpa)
[root@rhel8 ~]# httpd -v
Server version: Apache/2.4.37 (Red Hat Enterprise Linux)
Server built: Oct 26 2021 14:18:06
[root@rhel8 ~]# smbstatus --version
Version 4.14.5
```

# Make Share Folder
```
mkdir -p /share
chmod -R 775 /share
chown -R apache. /share
```

# Configure WebDAV
### Create new config file follwing:
```
vim /etc/httpd/conf.d/webdav.conf

# create new
<IfModule mod_dav_fs.c>
DAVLockDB /var/lib/dav/lockdb
</IfModule>
Alias /share /share
<Location /share>
DAV On
SSLRequireSSL
Options None
AuthType Basic
AuthName WebDAV
AuthUserFile /etc/httpd/conf/.htpasswd
<RequireAny>
Require method GET POST OPTIONS
Require valid-user
</RequireAny>
</Location>

```

### Create WebDAV User
> Note: This user is not your operating system's user.
```
htpasswd -c /etc/httpd/conf/.htpasswd <InputYourUserName>
New password: <InputYourPassword>
Re-type new password: <InputYourPassword>
Adding password for user <HereIsYourUserName>
```

### ~~(Optional) Edit Apache run user~~
It doesn't work.
```
vim /etc/httpd/conf/httpd.conf

69 #User apache
70 #Group apache
71 User cjl
72 Group cjl

```

### Start Apache
```
systemctl enable --now httpd
```

# (Optional) Configure SMB
When we want SMB to coexist with WebDAV.
```
vim /etc/samba/smb.conf

[global]
workgroup = WORKGROUP
security=user
map to guest =Bad User

#添加名为share的共享文件夹
[share]
comment = share all
path = /share
browseable = yes
public = yes
writable = yes
create mode = 0744
force create mode = 0744
directory mode = 0744
force directory mode = 0744
force user = apache
```

```
systemctl restart smb
```

# WebDAV Client
## Windows11
```
net use W: https://192.168.64.84:10443/share /user:cjh Passw0rd
```
> 注：此时该使用率为 C 盘使用率

![93f97ccc15849f38f8bc1e02178d4b98.png](/resources/c66e506b80dc4c7696a76e2d002a2f72.png)


![48b98cb67ab001de8adead97de6605f4.png](/resources/4c10e6a842fd4da0bb434d30eeeb9122.png)

![0e185d4f4e020542ea4470cbb2879782.png](/resources/56645ff907b0427fb4dcbd2cc397ef12.png)
![91c59f85f40de20ac4df8b55650b5d99.png](/resources/d7271438ef97408e953e8cf3ee39777f.png)
]


# 免密码登录

> 参考：https://httpd.apache.org/docs/2.4/mod/mod_dav.html

```
vim /etc/httpd/conf.d/webdav.conf

# create new
DAVLockDB /var/lib/dav/lockdb
Alias /share /share
<Directory "/share">
Require all granted
Dav On

AuthType Basic
AuthName DAV
AuthUserFile "user.passwd"

<LimitExcept GET POST OPTIONS>
Require user admin
</LimitExcept>
</Directory>
```
