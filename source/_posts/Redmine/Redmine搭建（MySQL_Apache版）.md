---
title: Redmine搭建（MySQL+Apache版）
date: 2021/10/26 15:42:55
categories:
  - Redmine
toc: true
#sidebar: none
---


# 0. 环境说明
### Redmine需要的环境：
- 能运行Ruby的OS
- 数据库（MySQL / PostgreSQL / SQLite / SQL服务器）
- 网站服务（Apache / Nginx ）

### 本次搭建环境：
| Software | Version | Command |
| -------- | ------- | ------- |
| OS| CentOS Linux release 8.4.2105 | cat /etc/os-release /etc/redhat-release /etc/system-release |
| Redmine | 4.2.3 | |
| MySQL | Ver 14.14 Distrib 5.7.36, for Linux (x86_64) using EditLine wrapper | mysql --version |
| MySQL | mysql Ver 8.0.26 for Linux on x86_64 (Source distribution) | mysql --version |
| Ruby | ruby 2.5.9p229 (2021-04-05 revision 67939) [x86_64-linux] | ruby -v |
| Apache | Apache/2.4.37 (centos) | apachectl -v |


# 1. 下载需要的软件包
```
dnf -y update
dnf -y groupinstall "Development Tools"
dnf -y install vim wget tar openssl* httpd httpd-devel ruby ruby-devel libcurl-devel
```

# 2. 安装数据库
## （选项1）2.1. 安装最新版的Mysql数据库（8.0.26）
```
dnf -y install mysql-server mysql-devel
```
## （选项2）2.2. 安装旧版的Mysql数据库（5.7.36）
```
wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
yum localinstall mysql57-community-release-el7-8.noarch.rpm
yum repolist enabled | grep "mysql.*-community.*"
yum module disable mysql
yum install mysql-community-server -y
systemctl enable mysqld
systemctl start mysqld
systemctl daemon-reload

```
## （选项3）2.3. 安装旧版的Mysql数据库（5.7.36）
```
wget http://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
rpm -ivh mysql80-community-release-el7-3.noarch.rpm
```
指定版本 (5.7)
```
cd /etc/yum.repos.d/
vim mysql-community.repo
```
![a8f7e14be6eda3ea928d1df2a0f7f0b6.png](/resources/67010a66a22e48c5b133de6df277264d.png)

```
yum -y module disable mysql
yum -y install mysql-community-server
```
确认
```
mysql --version
```
## （选项4）2.4. 获取数据库初始密码
（旧版数据库需要）
```
grep 'temporary password' /var/log/mysqld.log
```
## 2.5. 配置数据库
初始化数据库，根据需求选择 Y / N
```
mysql_secure_installation
```
为Redmine创建数据库
```
mysql -uroot -p

CREATE DATABASE redmine CHARACTER SET utf8mb4;
set global validate_password.policy=0; #密码策略为0这一步可选
CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'my_password'; #把'my_password'改为我们想要设定的密码
GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost';
```

重启数据库
```
systemctl enable mysqld
systemctl restart mysqld
```

# 3. 关闭Selinux
```
vim /etc/selinux/config
#SELINUX=enforcing

SELINUX=disabled
```
```
reboot
getenforce # 确认结果
```



# 4. 下载安装Redmine

> 获取最新版本:
> [Redmine官方下载地址](https://www.redmine.org/projects/redmine/wiki/Download)
## 4.1. 下载以及解压
```
wget https://www.redmine.org/releases/redmine-4.2.3.tar.gz
tar -zxvf redmine-4.2.3.tar.gz
mv redmine-4.2.3 /redmine
```
## 4.2. 配置database.yml文件
根据数据库设置，配置Redmine的连接数据库设定文件
```
cd /redmine/config/
cp database.yml.example database.yml
vim database.yml

production:
adapter: mysql2
database: redmine
host: localhost
username: redmine
password: "my_password"
# Use "utf8" instead of "utfmb4" for MySQL prior to 5.7.7
encoding: utf8mb4

```

> 注意：
> 要把development，test等区域给删了
> 排版缩进要正确！

## 4.3. 通过Ruby部署
我对Ruby不了解，这些命令不是很懂，似乎可以自动导入 Redmine 操作所需的 Ruby 软件包，为 MySQL 数据库创建所需的表或加载默认数据？注意不能忘了，在执行操作前移动到Redmine目录。

```
cd /redmine
gem install bundler
bundle install --without development test rmagick
bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake redmine:load_default_data

```
执行最后一行的时候选择想要的语言。


# 5. 配置Apache
## 5.1. 安装passenger
```
gem install passenger
passenger-install-apache2-module --auto --languages ruby
```
有大量的日志在画面上滚动，需要花一点时间。虽然有很多警告，但是如果不因错误而掉落的话应该没什么问题。
## 5.2. 安装snippet
```
[root@localhost redmine]# passenger-install-apache2-module --snippet
LoadModule passenger_module /usr/local/share/gems/gems/passenger-6.0.11/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
PassengerRoot /usr/local/share/gems/gems/passenger-6.0.11
PassengerDefaultRuby /usr/bin/ruby
</IfModule>
```

## 5.3. 设置Redmine为Apache的根目录，并把上一步5.2的结果复制下来粘贴到redmine.conf文件中
```
vim /etc/httpd/conf.d/redmine.conf

<Directory "/redmine/public">
Require all granted
</Directory>

LoadModule passenger_module /usr/local/share/gems/gems/passenger-6.0.11/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
PassengerRoot /usr/local/share/gems/gems/passenger-6.0.11
PassengerDefaultRuby /usr/bin/ruby
</IfModule>

```
## 5.4.
```
vim /etc/httpd/conf/httpd.conf

DocumentRoot "/redmine/public"
```

## 5.5. 给Apache权限
```
chown -R apache:apache /redmine
```

## 5.6. 重启Apache
```
systemctl enable httpd
systemctl start httpd

```
# 6. 防火墙
```
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
```

# 7. 排错
## 7.1. 删除Mysql数据库
```
dnf -y remove mysql mysql-server mysql-libs mysql-common
rm -rf /var/lib/mysql
```


> 参考：
> [Redmine官方安装教程](https://www.redmine.org/projects/redmine/wiki/redmineinstall)
> [CentOS8にRedmine4.1をインストールする](https://chiritsumon.net/contents/archives/2072)
>


```
[root@localhost ~]# sudo su - postgres
[postgres@localhost ~]$ psql
```
```
CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD 'Your_Password' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;
