---
title: Setup FTP server (vsftpd)
date: 2021/05/10 10:44:49
categories:
  - File Sharing Servers
toc: true
#sidebar: none
---

Socket Statistics

```shell
[root@localhost html]# ss -ntul
Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port
tcp LISTEN 0 128 0.0.0.0:22 0.0.0.0:*
tcp LISTEN 0 128 [::]:22 [::]:*
```

FTP server pakege install

```shell
yum install vsftpd -y
```
FW setting
```
firewall-cmd --zone=public --add-service=ftp --permanent
firewall-cmd --reload
```
必须设置selinux为关闭
1. 临时设置（重启失效）
```
[root@centos8 ~]# setenforce 0
[root@centos8 ~]# getenforce
Permissive
```
2. 永久设置
```
[root@centos8 ~]# vim /etc/selinux/config
#SELINUX=enforcing
SELINUX=disabled
[root@centos8 ~]# reboot
[root@centos8 ~]# getenforce
Disabled
```

FTP的配置文件
```shell
[root@localhost ~]# ls /etc/vsftpd/
ftpusers user_list vsftpd.conf vsftpd_conf_migrate.sh
```

备份主配置文件

```shell
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
```
FTP可以有三种登入方式分别是：
> 匿名登录方式：不需要用户密码
> 本地用户登入：使用本地用户和密码登入
> 虚拟用户方式：也是使用用户和密码登入，但是该用户不是linux中创建的用户
vsftpd.conf: 主配置文件

```
[root@centos8 ~]# vim /etc/vsftpd/vsftpd.conf
anonymous_enable=YEStt#允许匿名用户登陆
anon_upload_enable=YES tt#匿名用户可以上传文件
anon_mkdir_write_enable=YESt#匿名用户可以修改文件夹
anon_other_write_enable=YESt#匿名用户可以修改文件夹
no_anon_password=YEStt#匿名用户login时不询问口令
anon_umask=011tt#匿名用户创建文件的掩码，不指定时候为077

local_enable=YES #vsftpd所在系统的用户可以登录vsftpd
write_enable=YES #全局设置，是否容许写入（无论是匿名用户还是本地用户，若要启用上传权限的话，就要开启他）
local_umask=002 #匿名用户新增文件的umask数值
xferlog_enable=YES #启用一个日志文件，用于详细记录上传和下载。
use_localtime=YES #使用本地时间而不是GMT
vsftpd_log_file=/var/log/vsftpd.log #vsftpd日志存放位置
dual_log_enable=YES #用户登陆日志
connect_from_port_20=YES #开启20端口
xferlog_file=/var/log/xferlog #记录上传下载文件的日志
xferlog_std_format=YES #记录日志使用标准格式
idle_session_timeout=600 #登陆之后超时时间60秒，登陆之后，一分钟不操作，就会断开连接。
chroot_local_user=YES #用于指定用户列表文件中的用户,是否允许切换到上级目录
listen=YES #开启监听
pam_service_name=vsftpd.vu #验证文件的名字
userlist_enable=YES #允许由user_list指定文件中的用户登录FTP服务器
tcp_wrappers=YES #支持tcp_wrappers,限制访问(/etc/hosts.allow,/etc/hosts.deny)
guest_enable=YES #起用虚拟用户
guest_username=taokey #虚拟用户名

#user_config_dir=/etc/vsftpd/vsftpuser #虚拟用户配置文件路径
local_root=/home/ftpUser/ #自定义ftp上传路径（注意文件夹权限）
pasv_min_port=35000
pasv_max_port=45000
pasv_enable=YES
pasv_promiscuous=YES
anon_other_write_enable=YES

#
# 1. 监听相关
#
listen=<YES/NO> # YES: 服务以独立运行方式运行; NO: 运行在 xinetd 内。 默认为 YES
listen_address=<ip address> # 服务监听地址, 如果有多个网卡, 需要将服务绑定到指定 IP 地址
listen_port=<port> # 服务监听端口, 默认为 21

#
# 2. 匿名用户相关
#
anonymous_enable=<YES/NO> # 是否允许匿名用户访问, 默认 NO
no_anon_password=YES t # 匿名用户login时不询问口令
anon_mkdir_write_enable=<YES/NO> # 是否允许匿名用户创建文件夹, 默认 NO
anon_other_write_enable=<YES/NO> # 是否允许匿名用户重命名、删除文件夹等其他权限（默认为 NO, 基于安全性考虑这个权限一般不打开）
anon_upload_enable=<YES/NO> # 是否允许匿名用户上传, 默认 NO
anon_umask=<nnn> # 匿名用户上传的文件的生成掩码, 默认为077
anon_max_rate=<n> # 匿名用户的最大传输速率, 单位为 Byte/s, 值为 0 表示不限制
anon_world_readable_only=<YES/NO> # 是否允许匿名用户只读浏览

#
# 3. 本地用户(Linux标准系统用户)相关
#
local_enable=<YES/NO> # 是否支持本地用户帐号访问
write_enable=<YES/NO> # 是否开放本地用户的写权限
local_umask=<nnn> # 本地用户上传的文件的生成掩码, 默认为077
local_max_rate=<n> # 本地用户最大的传输速率, 单位为 Byte/s，值为 0 表示不限制
local_root=<file> # 本地用户登陆后的目录，默认为 本地用户 的 主目录

chroot_local_user=<YES/NO> # 本地用户是否可以执行 chroot, 默认为 NO
chroot_list_enable=<YES/NO> # 是否只有指定的用户才能执行 chroot, 默认为 NO
chroot_list_file=<filename> # 当 chroot_local_user=NO 且 chroot_list_enable=YES 时,
# 只有 filename 文件内指定的用户（每行一个用户名）可以执行 chroot,
# 默认值为 /etc/vsftpd.chroot_list

#
# 4. 本地用户 黑/白名单管理
#
userlist_enable=<YES/NO> # 是否启用 userlist_file 用户列表, 默认为 YES，设置为NO的时候，并且用户名不在黑名单（user_list）可以登录，并查看ls ~中的文件

userlist_deny=<YES/NO> # 当 userlist_enable=YES（即启用 userlist_file ）时, 则该字段才有效。
# userlist_deny=YES: userlist_file 为 黑名单, 即在该文件内的用户均不可登录, 其他用户可以登录
# userlist_deny=NO: userlist_file 为 白名单, 即在该文件内的用户才可以登录, 其他用户均不可登录

userlist_file=<filename> # 黑/白名单用户列表文件（每行一个用户名）,
# 是黑名单还是白名单, 根据 userlist_deny 的值决定,
# 默认值为 /etc/vsftpd/user_list

#
# 5. 连接相关
#
ftpd_banner=<message> # 客户端连接服务器后显示的欢迎信息
connect_timeout=<n> # 远程客户端响应端口数据连接超时时间, 单位为秒, 默认 60
accept_connection_timeout=<n> # 空闲的数据连接超时时间, 单位为秒, 默认 120
data_connection_timeout=<n> # 空闲的用户会话超时时间, 单位为秒, 默认 300
max_clients=<n> # 在独立模式运行时, 最大连接数, 0 表示无限制
max_per_ip=<n> # 在独立模式运行时, 每 IP 的最大连接数, 0表示无限制

```


另外默认Vsftpd匿名用户有两个：anonymous、ftp，所以匿名用户如果需要上传文件、删除及修改等权限，需要ftp用户对/var/ftp/pub目录有写入权限，使用如下chown和chmod任意一种即可，设置命令如下：
```
chown -R ftp /var/ftp/pub/
chgrp -R ftp /var/ftp/pub/
chmod -R 766 /var/ftp/pub/
```




确认端口开启状态
```shell
[root@localhost html]# systemctl start vsftpd
[root@localhost html]# ss -ntul
Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port
tcp LISTEN 0 128 0.0.0.0:22 0.0.0.0:*
tcp LISTEN 0 32 *:21 *:*
tcp LISTEN 0 128 [::]:22 [::]:*
```

