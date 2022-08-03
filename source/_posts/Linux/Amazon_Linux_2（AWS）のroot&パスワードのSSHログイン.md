---
title: Amazon Linux 2（AWS）のroot&パスワードのSSHログイン
date: 2022/08/03 10:21:22
tags:
  - linux
  - aws
categories:
  - Linux
toc: true
#sidebar: none
---

VNC からログインして、<kbd>E</kbd>を押します。
![vncviewer_1143x861_220803.png](/resources/60ef1180c9404fae9955e7419591ae73.png)

linux16の行の後ろに`rd.break`を追記し、<kbd>CTRL</kbd> + <kbd>X</kbd>を押し起動します。
![vncviewer_1143x861_220803_1.png](/resources/a87ec93a3244470c9c4609bdb8ba6144.png)

以下のように、rootファイルシステムを操作できる`switch_root:/#`コンソール画面にたどり着きました。
![vncviewer_1127x772_220803.png](/resources/a2dbd4a1eb5949ef846677664422bb7b.png)

以下のコマンドを入力して、パスワードを設定します。
```bash
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
```
![vncviewer_1127x772_220803_change_passwd.png](/resources/e142798769e049b8add32705c2fe2da6.png)

以下のコマンドを入力して、SeLinuxを設定して、再起動します。
```
touch /.autorelabel
exit
exit
```
![vncviewer_1127x772_220803_selinux.png](/resources/a8aea795b03e455aace65e8b005c17c3.png)


ログイン画面にたどり着きました、rootと先程設定したパスワードを入力して、ログインします。
![vncviewer_1127x772_220803_login.png](/resources/4c8ff34776b443aa8c82b80ac992bbe1.png)

OSをrootからログインできるように、`/etc/ssh/sshd_config` ファイルを以下２か所を編集します。

![vncviewer_1127x772_220803_PermitRootLogin.png](/resources/8a23132f267b4149b0efdf4f2f982885.png)

![vncviewer_1127x772_220803_PermitPasswdLogin.png](/resources/355440df0fbb4062b2558c3fa2c923cd.png)

以下のコマンドを入力して、`/etc/ssh/sshd_config` 設定を反映します。そして、OSのIPアドレスを調べます。
```
systemctl restart sshd
hostname -I
```

![vncviewer_1127x772_220803_getIP.png](/resources/08fead9e564e441aab1187f72102fb5b.png)

以上の操作で、Amazon Linux のroot のパスワードを設定したので、ssh からログインできる状態になりましたので、ssh からログインしましょう！
![WindowsTerminal_1118x718_220803.png](/resources/f1b7cbe8eaf64ad6bfbcdd9650e9ff37.png)

