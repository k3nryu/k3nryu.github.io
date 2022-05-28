---
title: Deploy Nginx, MySQL, PHP on Linux (LEMP/LNMP stack)
date: 2021/11/22
categories:
- Linux
tags:
- Server
- Nginx
- MySQL
- PHP
toc: true
#sidebar: none
---

| Name | Version | Command |
| -------- | ------- | ------- |
| Linux | Rocky Linux release 8.5 (Green Obsidian) | cat /etc/os-release /etc/redhat-release /etc/system-release |
| Nginx | nginx version: nginx/1.20.2 | nginx -v |
| MySQL | mysql Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL) | mysql --version |
| PHP | PHP 7.4.29 (cli) (built: Apr 12 2022 10:55:38) ( NTS ) | php -v |

# 0. Preparation
Check if old packages have been installed.
```
# rpm -qa | grep -E "nginx|php|mariadb"
```
If they are installed, remove them.
```
# yum remove -y "nginx*"
# yum remove -y "php*"
# yum remove -y "mariadb*"
```
# 1. Add repositories
### 1.1 Add Nginx Official repository
Create and edit the following file.
```
# vim /etc/yum.repos.d/nginx.repo
```

```
[nginx]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch
gpgcheck=1
enable=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
enabled=1
```
```
# yum-config-manager --enable nginx
# dnf config-manager --enable nginx
```
### 1.2 Add MySQL Official repositories
Download and install repositories form : [MySQL Community Downloads](https://dev.mysql.com/downloads/repo/yum/)
```
# dnf -y install https://repo.mysql.com//mysql80-community-release-el8-3.noarch.rpm
# dnf config-manager --enable mysql80-community
# yum repolist all | grep mysql
```
### 1.3 Add PHP repository
Execute the following commands in sequence to add and update epel repository.
```
# dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
# dnf module enable php:remi-7.4 -y
```

# 2. Installation
## 2.1 Install Nginx
```
# dnf -y install nginx
# nginx -v
```
## 2.2 Install MySQL
```
# yum module disable mysql -y
# yum install mysql-community-server -y
# mysql -V
```

## 2.3 Install PHP
```
# dnf install php php-curl php-dom php-exif php-fileinfo php-fpm php-gd php-hash php-json php-mbstring php-mysqli php-openssl php-pcre php-xml libsodium php-ldap php-pdo php-pear php-snmp php-xml -y
# php -v
```

# 3. Configuration
## 3.1 Configure Nginx
```
# systemctl enable --now nginx
```

```
# mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
# vim default.conf
```
```
location / {
root /usr/share/nginx/html;
- index index.html index.htm;
+ index index.html index.htm index.php;
}
location ~ .php$ {
root /usr/share/nginx/html;
fastcgi_pass unix:/run/php-fpm/www.sock;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
include fastcgi_params;
}
## Edit this file according to actual usage.
```
## 3.2 Configure MySQL
Start and set enabled the MySQL server
```
# systemctl enable --now mysqld
```
A superuser account 'root'@'localhost' is created. A password for the superuser is set and stored in the error log file. To reveal it, use the following command:
```
# grep 'temporary password' /var/log/mysqld.log
```

```
# mysql -uroot -p
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'Your_Password';
```
> MySQL's validate_password plugin is installed by default. This will require that passwords contain at least one uppercase letter, one lowercase letter, one digit, and one special character, and that the total password length is at least 8 characters.


> Reference site
> [A Quick Guide to Using the MySQL Yum Repository
](https://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/)
## 3.3 Configure PHP
```
# vim /etc/php-fpm.d/www.conf
```
```
- user = apache
+ user = nginx
- group = apache
+ group = nginx
```
```
# grep timezone /etc/php.ini
; Defines the default timezone used by the date functions
; http://php.net/date.timezone
date.timezone = Asia/Tokyo
```
```
# systemctl enable --now php-fpm
```

---
## (Optional) Verify environment configuration
Execute the following command to create test file.
> The root directory of the site that has been configured in `/usr/share/nginx/html`, This article uses thatdirectory as an example.
```
# echo "<?php phpinfo(); ?>" >> /usr/share/nginx/html/index.php
# nginx -t
# nginx -s reload
```
Modify the firewall policy to make the server can be accessed.
```
# firewall-cmd --permanent --add-port={443/tcp,80/tcp}
# firewall-cmd --reload
```


Access the following address in your browser.
http://your_lnmp_server_ip
![74cf5cec9ade58f2fb87e6003d42c459.png](/resources/a00140617cff48c9ab2405d7a47ee3fc.png)
http://your_lnmp_server_ip/index.php
![4a5b21722700b65b44b39fde5379768e.png](/resources/52ae4c9828d54beebfd2f823ba64d346.png)

If the results are displayed as above, the environment is successfully configured.
