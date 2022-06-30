---
title: LSI Storage Authority (LSA) on Linux
date: 2022/06/30 16:55:45
categories:
  - Storage
toc: true
#sidebar: none
---

[toc]




![chrome_1346x624_220630.png](/resources/0095ad2ae257418a89d9961bbf3343f3.png)

##### step0. firewall and selinux
```
firewall-cmd --add-port=2463/tcp --permanent
firewall-cmd --add-port=9000/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all

sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

reboot
```




##### step1. From following URL search your HBA controller and download LSA packages
https://www.broadcom.com/products/storage/raid-controllers
```
unzip x.x.x.x_LSA_Linux-x64.zip
```
##### step2. Download and install OpenSLP
http://www.openslp.org/download.html
```
yum groupinstall -y 'Development Tools'
wget https://jaist.dl.sourceforge.net/project/openslp/2.0.0/2.0.0%20Release/openslp-2.0.0.tar.gz
tar -zxvf openslp-2.0.0.tar.gz
cd openslp-2.0.0/
./configure
make && make install
/usr/local/sbin/slpd stop
```

##### step3. Install LSA
```
cd x.x.x.x_LSA_Linux-x64/x64/
./install.sh
ln -sf /usr/local/lib/libslp.so.1.0.0 /opt/lsi/LSIStorageAuthority/bin/libslp.so.1
/etc/init.d/LsiSASH restart
```

![chrome_1920x1032_220630 (2.png).png](/resources/0ce63fe5c4884710a862af6a0c13eca3.png)

![chrome_1920x955_220630 (2.png).png](/resources/fb45842d17a9474ba4afcd4215851e8e.png)


![chrome_1920x1032_220630.png](/resources/1fb96b3b6b20474eb0fe0443942834a0.png)



##### Uninstall
```
/opt/lsi/LSIStorageAuthority/uninstaller.sh
```
