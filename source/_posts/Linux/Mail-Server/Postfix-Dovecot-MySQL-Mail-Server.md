---
title: Postfix Dovecot MySQL Mail Server
date: 2022/5/2
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
# Objective
- Local network (web)mail server.
- Local private PKI.
- On LNMP-base use Postfix & Dovecot & PostfixAdmin & RoundCube.

| Name | Version | Command |
| -------- | ------- | ------- |
| Linux | Rocky Linux release 8.5 (Green Obsidian) | cat /etc/centos-release /etc/os-release /etc/redhat-release /etc/rocky-release /etc/system-release |
| Nginx | nginx version: nginx/1.20.2 | nginx -v |
| MySQL | mysql Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL) | mysql --version |
| PHP | PHP 7.4.29 (fpm-fcgi) (built: Apr 12 2022 10:55:38) | php -v |
| Postfix | mail_version = 3.5.8 | postconf mail_version |
| Dovecot | 2.3.8 (9df20d2db) | dovecot --version |
| PostfixAdmin | 3.3.11 | |
| Roundcube | 1.5.2 | |

# Prerequisites
- Have a host with CPU more than 1Core and Memory higher than 2GB.
- Have an LNMP-Base or LAMP-Base host;
- Have an FQDN that can be resolved;
- Have private CA root certificate, Host's private key, Host's certificate;

`free` command
```
# free -h
total used free shared buff/cache available
Mem: 1.9Gi 624Mi 746Mi 20Mi 606Mi 1.2Gi
Swap: 2.0Gi 0B 2.0Gi
```

DNS Record on name server:
```
mail.example.com. IN A 192.168.65.132
132.65 IN PTR mail.example.com.
```
SSL/TSL's private key and certificate file is following path :
```
[root@email ~]# ll /etc/pki/tls/certs/mail.example.com.crt
-r--r--r-- 1 root root 5439 Apr 23 16:41 /etc/pki/tls/certs/mail.example.com.crt
[root@email ~]#
[root@email ~]# ll /etc/pki/tls/private/mail.example.com.key
-r-------- 1 root root 1704 Apr 23 16:41 /etc/pki/tls/private/mail.example.com.key
```
# Step1. OS Setting
Setting hostname.
```
# dnf -y update
# hostnamectl set-hostname mail.example.com
```
```
# vim /etc/hosts
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4 mail.example.com
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6 mail.example.com
```
Disable SELinux
```
# sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
# reboot
```
Allow the following packages to pass though the firewall.
```
# firewall-cmd --permanent --add-service={http,https,smtp,smtp-submission,smtps,imap,imaps,pop3,pop3s}
# firewall-cmd --reload
# firewall-cmd --list-all
```
Install some required packages and recommended PHP modules.
```
# dnf -y install vim wget tar git nmap bind-utils telnet mailx openssl
# dnf -y install php php-fpm php-imap php-mbstring php-mysqlnd php-gd php-opcache php-json php-curl php-zip php-xml php-bz2 php-intl php-gmp
```
# Step2. Create Databases
Create a database for PostfixAdmin.
```
mysql> CREATE DATABASE postfixadmin;
mysql> CREATE USER 'postfixadmin'@'localhost' IDENTIFIED BY 'YourPassword';
mysql> GRANT ALL PRIVILEGES ON `postfixadmin` . _config.landscape.yml _config.yml db.json Get_Joplin_resources.sh i18n Install_JavaScripts_via_npm.sh node_modules package.json package-lock.json public scaffolds source symlink.sh test.md themes tmp.md TO 'postfixadmin'@'localhost';
mysql> FLUSH PRIVILEGES;
```
Create a database for roundcubu.
```
mysql> CREATE DATABASE roundcube DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
mysql> CREATE USER roundcube@localhost IDENTIFIED BY 'YourPassword';
mysql> GRANT ALL PRIVILEGES ON roundcube.* TO roundcube@localhost;
mysql> FLUSH PRIVILEGES;
```
# Step3. Create Web Servers
Create Nginx config file for PostfixAdmin and RoundCube.
```
# cat /etc/nginx/conf.d/mail.example.com.conf
# Redirect http to https.
server {
listen 80;
listen [::]:80;
server_name mail.example.com, 192.168.65.132;
return 301 https://mail.example.com$request_uri;
}

# Listen https://mail.example.com
server {
listen 443 ssl http2;
server_name mail.example.com;

# SSl/TLS configuration
ssl_certificate "/etc/pki/tls/certs/mail.example.com.crt";
ssl_certificate_key "/etc/pki/tls/private/mail.example.com.key";
ssl_session_cache shared:SSL:1m;
ssl_session_timeout 10m;
ssl_ciphers PROFILE=SYSTEM;
ssl_prefer_server_ciphers on;

# Roundcube configuration
root /usr/share/nginx/roundcube/;
index index.php index.html index.htm;

# Roundcube logs
error_log /var/log/nginx/roundcube.error;
access_log /var/log/nginx/roundcube.access;

# Roundcube Locations
location / {
try_files $uri $uri/ /index.php;
}
location ~ .php$ {
try_files $uri =404;
fastcgi_pass unix:/run/php-fpm/www.sock;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
include fastcgi_params;
}
location ~ /.well-known/acme-challenge {
allow all;
}
location ~ ^/(README|INSTALL|LICENSE|CHANGELOG|UPGRADING)$ {
deny all;
}
location ~ ^/(bin|SQL)/ {
deny all;
}

# Sub-Location of PostfixAdmin
location /postfixadmin {
alias /usr/share/nginx/postfixadmin/public;
access_log /var/log/nginx/postfixadmin_access.log;
error_log /var/log/nginx/postfixadmin_error.log;
try_files $uri $uri/ /index.php;

location ~ ^/(.+.php)$ {
try_files $uri =404;
fastcgi_pass unix:/run/php-fpm/www.sock;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME $request_filename;
include /etc/nginx/fastcgi_params;
}
}

# A long browser cache lifetime can speed up repeat visits to your page
# location ~* .(jpg|jpeg|gif|png|webp|svg|woff|woff2|ttf|css|js|ico|xml)$ {
# access_log off;
# log_not_found off;
# expires 360d;
# }

}
```

# Step4. Configure Postfix
Install and start Postfix.
```
# dnf -y install postfix postfix-mysql
# systemctl enable --now postfix
```
Edit Postfix main config file with following command. This will defined our `domain` `hostname` `tls_level` etc...
```
# cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
# vim /etc/postfix/main.cf
```
[main.cf](/resources/0e222d97baca4600b523da77666a1419.cf)

We can configure postfix by direct modifying above file or use following `postconf` command.
```
Change to:
# postconf -e "inet_interfaces = all"
# postconf -e 'inet_protocols = ipv4'
# postconf 'smtpd_tls_cert_file = /etc/pki/tls/certs/mail.example.com.crt'
# postconf 'smtpd_tls_key_file = /etc/pki/tls/private/mail.example.com.key'
Add:
# postconf -e 'smtp_address_preference = ipv4'
# postconf "smtpd_tls_loglevel = 1"
# postconf "smtp_tls_loglevel = 1"

```
```
#Add following to the end of the file.
# Force TLSv1.3 or TLSv1.2
smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtpd_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1

mailbox_transport = lmtp:unix:private/dovecot-lmtp
smtputf8_enable = no

virtual_mailbox_domains = proxy:mysql:/etc/postfix/sql/mysql_virtual_domains_maps.cf
virtual_mailbox_maps =
proxy:mysql:/etc/postfix/sql/mysql_virtual_mailbox_maps.cf,
proxy:mysql:/etc/postfix/sql/mysql_virtual_alias_domain_mailbox_maps.cf
virtual_alias_maps =
proxy:mysql:/etc/postfix/sql/mysql_virtual_alias_maps.cf,
proxy:mysql:/etc/postfix/sql/mysql_virtual_alias_domain_maps.cf,
proxy:mysql:/etc/postfix/sql/mysql_virtual_alias_domain_catchall_maps.cf
virtual_transport = lmtp:unix:private/dovecot-lmtp

virtual_mailbox_base = /var/vmail
virtual_minimum_uid = 2000
virtual_uid_maps = static:2000
virtual_gid_maps = static:2000
```
Enable Submssion port (587) and SMTP-S (465) by editting `/etc/postfix/master.cf` file.
```
# cp /etc/postfix/master.cf /etc/postfix/master.cf.bak
# vim /etc/postfix/master.cf
```


[master.cf](/resources/aef18d6512de4fffa179363b41ca9710.cf)


```
# For Submission
submission inet n - y - - smtpd
-o syslog_name=postfix/submission
-o smtpd_tls_security_level=encrypt
-o smtpd_tls_wrappermode=no
-o smtpd_sasl_auth_enable=yes
-o smtpd_relay_restrictions=permit_sasl_authenticated,reject
-o smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject
-o smtpd_sasl_type=dovecot
-o smtpd_sasl_path=private/auth

# For SMTP-S
smtps inet n - y - - smtpd
-o syslog_name=postfix/smtps
-o smtpd_tls_wrappermode=yes
-o smtpd_sasl_auth_enable=yes
-o smtpd_relay_restrictions=permit_sasl_authenticated,reject
-o smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject
-o smtpd_sasl_type=dovecot
-o smtpd_sasl_path=private/auth
```

(Option) We can follow the steps below to create a watchdog to prevent the service from terminating unexpectedly.
```
# mkdir -p /etc/systemd/system/postfix.service.d/
# vim /etc/systemd/system/postfix.service.d/restart.conf
[Service]
Restart=on-failure
RestartSec=5s
```
(Option) Verify the watchdog is working.
```
# systemctl daemon-reload
# pkill master
# systemctl status postfix
```
# Step5. Configure Dovecot
```
# dnf -y install dovecot dovecot-mysql
# systemctl enable --now dovecot
```
Add the dovecot to the mail group.
```
# gpasswd -a dovecot mail
```
Add the web server(nginx) to the dovecot group.
```
# gpasswd -a nginx dovecot
```
Generating DH parameters, This is going to take a long time.
```
# openssl dhparam -out /etc/dovecot/dh.pem 4096
```
Uncomment following line and remove ~~submission~~ because we have enabled submission using Postfix.
```
# cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.bak
# vim /etc/dovecot/dovecot.conf
#protocols = imap pop3 lmtp submission
protocols = imap pop3 lmtp
```
Create new file and fill in the following. This will enable Dovecot to connect to our MySQL database.
```
# vim /etc/dovecot/dovecot-sql.conf.ext
```
```
driver = mysql
connect = host=localhost dbname=postfixadmin user=postfixadmin password=YourPassword
default_pass_scheme = SHA512
password_query = SELECT username AS user,password FROM mailbox WHERE username = '%u' AND active='1'
user_query = SELECT maildir, 2000 AS uid, 2000 AS gid FROM mailbox WHERE username = '%u' AND active='1'
iterate_query = SELECT username AS user FROM mailbox
```
Modify the file as below. This will define the mail location as well as the namespace.
```
# vim /etc/dovecot/conf.d/10-mail.conf
# Add following in the end.
mail_location = maildir:~/Maildir
mail_home = /var/vmail/%d/%n
mail_privileged_group = mail
```
Add the following lines to the end of this file.
```
# cp /etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf.bak
# vim /etc/dovecot/conf.d/10-master.conf
```
```
#Add following in the end of the file.
service stats {
unix_listener stats-reader {
user = nginx
group = nginx
mode = 0660
}
unix_listener stats-writer {
user = nginx
group = nginx
mode = 0660
}
}
```
Configuring Authentication Mechanism.
```
# cp /etc/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf.bak
# vim /etc/dovecot/conf.d/10-auth.conf
#Change to:
auth_username_format = %u
auth_mechanisms = plain login
!include auth-sql.conf.ext
auth_debug = yes
auth_debug_passwords = yes
```
Configuring SSL/TLS Encryption.
```
# cp /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.bak
# vim /etc/dovecot/conf.d/10-ssl.conf
#Change to:
ssl = required
ssl_cert = </etc/pki/tls/certs/mail.example.com.crt
ssl_key = </etc/pki/tls/private/mail.example.com.key
ssl_dh = </etc/dovecot/dh.pem
ssl_min_protocol = TLSv1.2
ssl_cipher_list = PROFILE=SYSTEM
ssl_prefer_server_ciphers = yes
```
SASL Authentication Between Postfix and Dovecot.
```
# vim /etc/dovecot/conf.d/10-master.conf
# Change to:
service lmtp {
unix_listener /var/spool/postfix/private/dovecot-lmtp {
mode = 0600
user = postfix
group = postfix
}
}
service auth {
unix_listener /var/spool/postfix/private/auth {
mode = 0600
user = postfix
group = postfix
}
}
```
Edit the following file like below. This will auto-create `Sent` ,`Junk`, `Drafts`and `Trash` Folder.
```
# cp /etc/dovecot/conf.d/15-mailboxes.conf /etc/dovecot/conf.d/15-mailboxes.conf.bak
# vim /etc/dovecot/conf.d/15-mailboxes.conf
namespace inbox {
# These mailboxes are widely used and could perhaps be created automatically:
mailbox Drafts {
auto = create
special_use = Drafts
}
mailbox Junk {
auto = create
special_use = Junk
}
mailbox Trash {
auto = create
special_use = Trash
}
mailbox Sent {
auto = create
special_use = Sent
}
mailbox "Sent Messages" {
special_use = Sent
}
}
```
Now we need to restart the Postfix and dovecot services.
```
# systemctl restart postfix dovecot
# systemctl status postfix
# systemctl status dovecot
```
# Step6. Configure Postfixadmin
Check https://github.com/postfixadmin/postfixadmin/releases to get the latest stable release first. And then we need to download the tarball via `wget` command.
```
# wget https://github.com/postfixadmin/postfixadmin/archive/postfixadmin-3.3.11.tar.gz
# tar -zxvf postfixadmin-3.3.11.tar.gz
# mv postfixadmin-postfixadmin-3.3.11/ /usr/share/nginx/postfixadmin
# mkdir -p /usr/share/nginx/postfixadmin/templates_c
```
Create the following new file and fill it like below. This will enable PostfixAdmin connect MySQL database and update password by PHP.
```
# vim /usr/share/nginx/postfixadmin/config.local.php
<?php
$CONF['configured'] = true;
$CONF['database_type'] = 'mysqli';
$CONF['database_host'] = 'localhost';
$CONF['database_port'] = '3306';
$CONF['database_user'] = 'postfixadmin';
$CONF['database_password'] = 'YourPassword';
$CONF['database_name'] = 'postfixadmin';
$CONF['encrypt'] = 'dovecot:SHA512';
$CONF['dovecotpw'] = "/usr/bin/doveadm pw -r 12";
?>
```
```
# chown -R nginx:nginx /usr/share/nginx/postfixadmin/
```
Make following directory.
```
# mkdir -p /etc/postfix/sql/
```
Create following files and make sure they are set with permissions to be accessible by Postfix user.
```
# vim /etc/postfix/sql/mysql_virtual_domains_maps.cf
user = postfixadmin
password = YourPassword
hosts = localhost
dbname = postfixadmin
query = SELECT domain FROM domain WHERE domain='%s' AND active = '1'
#query = SELECT domain FROM domain WHERE domain='%s'
#optional query to use when relaying for backup MX
#query = SELECT domain FROM domain WHERE domain='%s' AND backupmx = '0' AND active = '1'
#expansion_limit = 100
```
```
# vim /etc/postfix/sql/mysql_virtual_mailbox_maps.cf
user = postfixadmin
password = YourPassword
hosts = localhost
dbname = postfixadmin
query = SELECT maildir FROM mailbox WHERE username='%s' AND active = '1'
#expansion_limit = 100
```
```
# vim /etc/postfix/sql/mysql_virtual_alias_domain_mailbox_maps.cf
user = postfixadmin
password = YourPassword
hosts = localhost
dbname = postfixadmin
query = SELECT maildir FROM mailbox,alias_domain WHERE alias_domain.alias_domain = '%d' and mailbox.username = CONCAT('%u', '@', alias_domain.target_domain) AND mailbox.active = 1 AND alias_domain.active='1'
```
```
# vim /etc/postfix/sql/mysql_virtual_alias_maps.cf
user = postfixadmin
password = YourPassword
hosts = localhost
dbname = postfixadmin
query = SELECT goto FROM alias WHERE address='%s' AND active = '1'
#expansion_limit = 100
```
```
# vim /etc/postfix/sql/mysql_virtual_alias_domain_maps.cf
user = postfixadmin
password = YourPassword
hosts = localhost
dbname = postfixadmin
query = SELECT goto FROM alias,alias_domain WHERE alias_domain.alias_domain = '%d' and alias.address = CONCAT('%u', '@', alias_domain.target_domain) AND alias.active = 1 AND alias_domain.active='1'
```
```
# vim /etc/postfix/sql/mysql_virtual_alias_domain_catchall_maps.cf
user = postfixadmin
password = YourPassword
hosts = localhost
dbname = postfixadmin
query = SELECT goto FROM alias,alias_domain WHERE alias_domain.alias_domain = '%d' and alias.address = CONCAT('@', alias_domain.target_domain) AND alias.active = 1 AND alias_domain.active='1'
```
```
# chmod 0640 /etc/postfix/sql/*
```
```
# adduser vmail --system --uid 2000 --user-group --no-create-home
# mkdir /var/vmail/
# chown vmail:vmail /var/vmail/ -R
# chown -R postfix:postfix /etc/postfix/sql/
# chown -R nginx:nginx /var/lib/php/opcache/
# chown -R nginx:nginx /var/lib/php/session/
# chown -R nginx:nginx /var/lib/php/wsdlcache/
# chown nginx:nginx /etc/pki/tls/certs/mail.example.com.crt
# chown nginx:nginx /etc/pki/tls/private/mail.example.com.key
```
```
# nginx -t
# nginx -s reload
```
Open our browser and enter following URL to complete PostfixAdmin setup.
https://mail.example.com/postfixadmin/setup.php
![d470a41ee4e4f239da08aa8cce8454e6.png](/resources/56ef873134dc4730af5e4c076f0a142d.png)
You can generate a password hash through `php -r 'echo password_hash("YourPassword", PASSWORD_DEFAULT);'` command.
Now you need to add following line to the `/usr/share/nginx/postfixadmin/config.local.php` file in the end.
```
$CONF['setup_password'] = 'Your_Password's_Hash';
```
Follow the setup wizard to create an Administrator user and login.
![3033bf031c1ee6c2d69ada9fd9efacb9.png](/resources/968a63824b734664bdf63ddc612b5149.png)
Now you can create Domain and Mailboxes in PostfixAdmin.


> Reference:
> https://github.com/postfixadmin/postfixadmin/tree/master/DOCUMENTS
> https://raw.githubusercontent.com/postfixadmin/postfixadmin/master/INSTALL.TXT

# Step7. Configure RoundCube
RoundCube is a WebGUI IMAP client.
Download Roundcube Webmail from [https://github.com/roundcube/roundcubemail/releases](https://github.com/roundcube/roundcubemail/releases)

```
# wget https://github.com/roundcube/roundcubemail/releases/download/1.5.2/roundcubemail-1.5.2-complete.tar.gz
# tar -zxvf roundcubemail-1.5.2-complete.tar.gz
# mv roundcubemail-1.5.2 /usr/share/nginx/roundcube
# chown nginx:nginx -R /usr/share/nginx/roundcube/
# dnf install php-ldap php-imagick php-common php-gd php-imap php-json php-curl php-zip php-xml php-mbstring php-bz2 php-intl php-gmp -y
```
Add your Private CA's certificate in the end of the following file.
> Note: This needs to be saved forcibly with `:wq!`.
```
# vim /etc/pki/tls/certs/ca-bundle.crt
#Add the following to the end of the file.
# My Private CA Certificate.
-----BEGIN CERTIFICATE-----
...
Your CA certificate.
...
-----END CERTIFICATE-----
```
Now you need to open your browser and enter following URL to continue RoundCube setup.
https://email.example.com/installer
![3de277f1cb80d92e700afa2291ec518e.png](/resources/da9e0417bc4148dc84619435b459a634.png)

Fill Database setup.
![4cc2d3c216084c4f53fe8d31790cc077.png](/resources/1280d8cac4354e059b2d5bdb569f553c.png)
Fill IMAP setup.
IMAP server: `ssl://email.example.com` port: 993
![17011cf931373d801743e7e838af5caa.png](/resources/15047935b37a48d8b80e2e96113edfdd.png)
SMTP server: `tls://email.example.com` port: 587
SMTP server: `ssl://email.example.com` port: 465
![9cf36687ab8c8aa16a10237452a68fc4.png](/resources/ef129191e5c6400bb41f2b264df87b1f.png)
Next, you can scroll down to the Plugins section to enable some plugins. For example: the password plugin, mark as junk plugin and so on. I enabled all of them.
![25aa9951a611254091e5c49fe38f0546.png](/resources/4cf2d9a8596b47dea678335543e9b345.png)
![1c5dfe3f1776c20a82dc3767da2f8615.png](/resources/202413271cbf457ba0f75f5874a0bc9d.png)
![9dc291c4498b0bd990eb5576c49d6af0.png](/resources/f847d7cf9b224785b8482e7559a472e8.png)
Make sure the password plugin in the plugin list at the end of this file. The plugin order doesn’t matter.
```
# grep 'password' /usr/share/nginx/roundcube/config/config.inc.php
```
Create the new PHP file by copying the file below and modify it like following. This will enable RoundCube to connect our MySQL database and update password.
```
# cp /usr/share/nginx/roundcube/plugins/password/config.inc.php.dist /usr/share/nginx/roundcube/plugins/password/config.inc.php
vim /usr/share/nginx/roundcube/plugins/password/config.inc.php
```
```
#Change the value to:
$config['password_db_dsn'] = 'mysql://postfixadmin:YourPassword@127.0.0.1/postfixadmin';
$config['password_query'] = 'UPDATE mailbox SET password=%D,modified=NOW() WHERE username=%u';
$config['password_strength_driver'] = 'zxcvbn';
$config['password_zxcvbn_min_score'] = 5;
$config['password_algorithm'] = 'dovecot';
$config['password_dovecotpw'] = '/usr/bin/doveadm pw -r 12';
$config['password_dovecotpw_method'] = 'SHA512';
$config['password_dovecotpw_with_method'] = true;
```

[config.inc.php](/resources/dea4c2783658451c979438a687261219.php)

```
# chown nginx:nginx /usr/share/nginx/roundcube/plugins/password/config.inc.php
# chmod 600 /usr/share/nginx/roundcube/plugins/password/config.inc.php
# echo "$config['enable_installer'] = true;" >> /usr/share/nginx/roundcube/config/config.inc.php
```
Close the browser and enter following URL to complete set up.
https://email.example.com/installer/index.php?_step=3
Send test
![c9e11f23949605bfd8b04455e627ffeb.png](/resources/b9bf213308ec4609b63b6b12e9ceb9c3.png)
![aa845e73437a5ee48f3dda613c050b77.png](/resources/91a0bc77b06f4a1daee68fb7a6826d79.png)
Login test
![5be748fdc44ae54c05b97fc308998f63.png](/resources/2f69fc9c3e3045a28a29277368d8412a.png)
After completing the installation and the final tests please remove the whole installer folder from the document root of the webserver or make sure that enable_installer option in config.inc.php is disabled.

```
# rm -rf /usr/share/nginx/roundcube/installer/
vim /usr/share/nginx/roundcube/config/config.inc.php
Change to:
$config['enable_installer']=false;
```
```
# nginx -t
# nginx -s reload
```
Close the browser and enter following URL to login your account.
https://mail.example.com/postfixadmin/setup.php
https://mail.example.com

> Reference:
> https://www.linuxbabe.com/redhat/postfixadmin-create-virtual-mailboxes-centos-mail-server
> https://www.linuxbabe.com/redhat/install-roundcube-webmail-centos-8-rhel-8-apache-nginx#out-of-office

# TroubleShooting
Perform a user lookup in Dovecot's userdbs.
```
# doveadm user '*'
```
```
# journalctl -eu dovecot
# vim /var/log/maillog
# mail user@gmail.com
# vim /etc/aliases
# newaliases
```

