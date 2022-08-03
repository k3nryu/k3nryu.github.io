---
title: phpipam
date: 2022/04/19 17:58:10
categories:
  - Linux
toc: true
#sidebar: none
---

LNMP
[toc]

| Name | Version | Command |
| -------- | ------- | ------- |
| phpIPAM | 1.5 | cd /var/www/phpipam/ && git log |
| Linux | Rocky Linux release 8.5 (Green Obsidian) | cat /etc/lsb-release /etc/os-release |
| Nginx | nginx version: nginx/1.20.2 | nginx -v |
| MySQL | mysql Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL) | mysql --version |
| PHP | PHP 7.3.20 (cli) (built: Jul 7 2020 07:53:49) ( NTS ) | php -v |

## phpipam
```
dnf -y install php-gmp git
git clone https://github.com/phpipam/phpipam.git /var/www/phpipam
chown -R nginx:nginx /var/www/phpipam
cp /var/www/phpipam/config.dist.php /var/www/phpipam/config.php
```
```
vim /var/www/phpipam/config.php
```
```
$db['host'] = '127.0.0.1';
$db['user'] = 'phpipam';
$db['pass'] = 'Your_Password';
$db['name'] = 'phpipam';
$db['port'] = 3306;
```
## MySQL
```
# mysql -u root -p
mysql> create database phpipam;
mysql> create user phpipam@localhost identified with mysql_native_password by 'P@ssw0rd';
mysql> GRANT ALL PRIVILEGES ON phpipam.* TO phpipam@localhost;
mysql> flush privileges;
```
## PHP
```
vim /etc/php-fpm.d/www.conf
```
```
- user = apache
- group = apache
+ user = nginx
+ group = nginx
+ listen.owner = nginx
+ listen.group = nginx
+ listen.mode = 0660
```

```
echo "<?php phpinfo(); ?>" >> /usr/share/nginx/html/index.php
systemctl restart php-fpm.service
```
## Nginx
Backup nginx default config file.
```
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
```
Edit site config file .
```
vim /etc/nginx/conf.d/ipam.kensho.toda.conf
```
```
server {
listen 443 ssl http2;
server_name ipam.kensho.toda;
root /var/www/phpipam;
index index.php;

ssl_certificate "/etc/pki/nginx/ipam.kensho.toda.crt";
ssl_certificate_key "/etc/pki/nginx/private/ipam.kensho.toda.key";
ssl_session_cache shared:SSL:1m;
ssl_session_timeout 10m;
ssl_ciphers PROFILE=SYSTEM;
ssl_prefer_server_ciphers on;

location / {
try_files $uri $uri/ /phpipam/index.php;
index index.php;
}
location /api/ {
try_files $uri $uri/ /phpipam/api/index.php;
}
location ~ \.php$ {
fastcgi_pass unix:/run/php-fpm/www.sock;
fastcgi_index index.php;
try_files $uri $uri/ index.php = 404;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
include fastcgi_params;
}
}
server {
listen 80;
server_name ipam.kensho.toda;
return 301 https://ipam.kensho.toda$request_uri;
}
```

```
nginx -t
nginx -s reload
```

## Complete the initial configuration wizard
![c82bd586d5a8c037e3ae38c9c9e04aaa.png](/resources/e20d331a346c4df1a9d79f0280535d60.png)

![73a9d5e21d38e3d58c7cd9d6778e4a67.png](/resources/2efc6bc066444483937a6857aa8290bc.png)

The default Login credentials are:
- Username: admin
- Password: ipamadmin


## Toubleshoting
Reset phpipam admin password.
```
php /var/www/phpipam/functions/scripts/reset-admin-password.php
```
Check database's user.
```
# mysql -u root -p
mysql> use mysql;
mysql> select user,host,plugin from user;
```
## Schedule check-ip via cron
```
# crontab -e
*/15 Install_JavaScripts_via_npm.sh README.md _config.landscape.yml _config.yml db.json i18n joplin2hexo node_modules package.json public scaffolds source themes tmp Install_JavaScripts_via_npm.sh README.md _config.landscape.yml _config.yml db.json i18n joplin2hexo node_modules package.json public scaffolds source themes tmp Install_JavaScripts_via_npm.sh README.md _config.landscape.yml _config.yml db.json i18n joplin2hexo node_modules package.json public scaffolds source themes tmp Install_JavaScripts_via_npm.sh README.md _config.landscape.yml _config.yml db.json i18n joplin2hexo node_modules package.json public scaffolds source themes tmp root /usr/bin/php /var/www/phpipam/functions/scripts/pingCheck.php
*/15 Install_JavaScripts_via_npm.sh README.md _config.landscape.yml _config.yml db.json i18n joplin2hexo node_modules package.json public scaffolds source themes tmp Install_JavaScripts_via_npm.sh README.md _config.landscape.yml _config.yml db.json i18n joplin2hexo node_modules package.json public scaffolds source themes tmp Install_JavaScripts_via_npm.sh README.md _config.landscape.yml _config.yml db.json i18n joplin2hexo node_modules package.json public scaffolds source themes tmp Install_JavaScripts_via_npm.sh README.md _config.landscape.yml _config.yml db.json i18n joplin2hexo node_modules package.json public scaffolds source themes tmp root /usr/bin/php /var/www/phpipam/functions/scripts/discoveryCheck.php
# crontab -l
```

# Reference
1. [https://github.com/phpipam/phpipam](https://github.com/phpipam/phpipam)
2. [https://phpipam.net/documents/installation/](https://phpipam.net/documents/installation/)
3. [https://phpipam.net/news/phpipam-on-nginx/](https://phpipam.net/news/phpipam-on-nginx/)
4. [https://computingforgeeks.com/install-and-configure-phpipam-on-ubuntu-debian-linux/](https://computingforgeeks.com/install-and-configure-phpipam-on-ubuntu-debian-linux/)
