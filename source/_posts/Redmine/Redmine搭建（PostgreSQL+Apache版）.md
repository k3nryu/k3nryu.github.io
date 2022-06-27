---
title: Redmine搭建（PostgreSQL+Apache版）
date: 2021/10/27 16:41:47
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
| Postgresql | postgres (PostgreSQL) 10.17 | postgres -V |
| Ruby | ruby 2.5.9p229 (2021-04-05 revision 67939) [x86_64-linux] | ruby -v |
| Apache | Apache/2.4.37 (centos) | apachectl -v |


# 1. 下载需要的软件包
```
dnf -y update
dnf -y groupinstall "Development Tools"
dnf -y install vim wget tar openssl* httpd httpd-devel ruby ruby-devel libcurl-devel
```

# 2. 安装数据库
```
dnf -y install postgresql-server postgresql-devel
rpm -qa | grep postgresql
```
初始化数据库
```
postgresql-setup initdb
```
开机自动启动
```
systemctl enable --now postgresql
systemctl status postgresql
```

创建redmine用户以及redmine数据库

```
[root@localhost ~]# su - postgres
[postgres@localhost ~]$ psql
CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD 'Your_Password' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;
```

```
\du #查看用户
\l #查看数据库
\q #退出
```

编辑pg_hba.conf文件
```
vim /var/lib/pgsql/data/pg_hba.conf
# configuration parameter, or via the -i or -h command line switches.

host redmine redmine 127.0.0.1/32 md5
host redmine redmine ::1/128 md5
```
> 注意：
> 添加的规则放在73行的: configuration parameter...下面。否则会出现`psql: FATAL: Ident authentication failed for user "postgres"` 的错误而且无法访问数据库的问题。


重启数据库
```
systemctl restart postgresql
```
验证看看能不能正常访问数据库
```
psql -U redmine -d redmine -h 127.0.0.1
Password for user redmine: #←正常情况下会提示输入密码

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

###postgresql
production:
adapter: postgresql
database: redmine
host: localhost
username: redmine
password: "Your_Password"
encoding: utf8
t#pool: 5
```

> 注意：
> 要把development，test等区域给删了
> 排版缩进要正确！

## 4.3. 通过Ruby部署
我对Ruby不了解，这些命令不是很懂，似乎可以自动导入 Redmine 操作所需的 Ruby 软件包，为 MySQL 数据库创建所需的表或加载默认数据？注意不能忘了，在执行操作前移动到Redmine目录。

```
cd /redmine
gem install bundler --no-rdoc --no-ri
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
## 7.1. 删除PostgreSQL数据库以及用户
```
[root@localhost ~]# su - postgres
[postgres@localhost ~]$ psql
drop database redmine;
drop role redmine;
```

```
\du #查看用户
\l #查看数据库
\q #退出
```

> 参考：
> [Redmine官方安装教程](https://www.redmine.org/projects/redmine/wiki/redmineinstall)
> [CentOS8にRedmine4.1をインストールする](https://chiritsumon.net/contents/archives/2072)
> [如何在 CentOS 8 上安装 Postgresql
](https://cloud.tencent.com/developer/article/1626834)



