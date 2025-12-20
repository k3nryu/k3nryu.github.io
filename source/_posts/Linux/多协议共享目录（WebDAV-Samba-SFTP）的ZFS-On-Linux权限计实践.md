---
title: 多协议共享目录（WebDAV / Samba / SFTP）的 ZFS on Linux权限设计实践
date: 2025/12/20 18:27:00
tags:
  - linux
  - storage
  - smb
  - webdav
  - sftp
categories:
  - Linux
toc: true
#sidebar: none
---

## 一、背景（Background）

在家庭或小型团队环境中，经常会遇到一个共享目录需要同时被多种协议访问同一个文件夹的情况。例如：

- **WebDAV**：用于网页或移动端访问（Apache / Nginx）
- **Samba (SMB)**：用于 Windows / macOS 文件共享
- **SFTP**：用于 SSH 方式的文件管理

本文以 `/share` 目录为例，用户非常简单：
- 我：`k3nryu`
- 老婆：`xiaowu`
- WebDAV 服务用户：`www-data`
- 管理用户：`root`

但问题恰恰出在：**不同协议在 Linux 下会映射成不同的用户和组**。

### 实际遇到的问题
我创建的文件的时候，权限组将会是k3nryu:k3nryu，那么我老婆也编辑不了我的文件。
原因是不同访问方式创建的文件，其属主和属组如下：

| 访问方式 | Linux 看到的用户:组 |
|--------|------------------|
| WebDAV | www-data:www-data |
| Samba（我） | k3nryu:k3nryu |
| Samba（老婆） | xiaowu:xiaowu |
| SFTP | root:root |

导致的问题：

- A 创建的文件，B 无法读写
- root 创建的文件，普通用户没权限
- 子目录权限逐渐失控
- 不同服务的 umask 互相冲突

---
## 二、需求（Requirements）

### 目标需求

> **无论通过 WebDAV / Samba / SFTP / 本地 shell：**
>
> - 在 `/share`（及其子目录）中创建的文件
> - 所有相关用户都拥有 `rwx` 权限
> - 权限行为长期稳定、无需频繁维护

| 访问方式 | Linux 看到的用户:组 |
|--------|------------------|
| WebDAV | www-data:share |
| Samba（我） | k3nryu:share |
| Samba（老婆） | xiaowu:share |
| SFTP | root:share |

---

## 三、理论（Theory）

### 1. Linux 权限的本质

Linux 内核只关心三件事：

- **UID（用户）**
- **GID（组）**
- **权限位 / ACL**

它并不知道：

- WebDAV
- Samba
- SFTP

这些“协议用户”最终都会被映射成 **Linux 用户**，再由内核进行权限判断。

### 2. 设计核心思想

> **不要围绕“用户”设计权限，而要围绕“共享组（group）”设计权限**

关键技术组合：

| 技术 | 作用 |
|----|----|
| 共享 group | 表达“谁属于共享成员” |
| setgid | 保证新文件继承 group |
| ACL | 覆盖不同服务的 umask |
| sticky bit（可选） | 防止误删他人文件 |

---

## 四、实际操作（Implementation）

以下操作假设共享目录为 `/share`。

### 1. 创建统一共享组

```bash
groupadd share
```

将所有相关用户加入该组：

```bash
usermod -aG share k3nryu
usermod -aG share xiaowu
usermod -aG share www-data
usermod -aG share root
```

> 修改组后需重新登录或重启相关服务。

---

### 2. 设置目录属组并启用 setgid

```bash
chown -R www-data:share /share
chmod -R 2775 /share
```

检查效果：

```bash
ls -ld /share
```

期望看到：

```
drwxrwsr-x  www-data share /share
```

其中 `s` 表示 **setgid**，新建文件会自动继承 `share` 组。

---

### 3. （Optional）开启ZFS的POSIX模式的ACL
> 如果使用 ZFS文件系统的话，那么它的默认ALC模式是NFSv4 ACL（Solaris 的 chmod A+）.   
> 另外一方面setfacl / getfacl只支持 Linux POSIX ACL。所以我需要提前将ZFS的ALC模式调整为POSIX。

```
zfs set acltype=posixacl tank
zfs set aclinherit=passthrough tank
zfs set aclmode=passthrough tank
zfs get acltype,aclinherit,aclmode tank
```

### 4. 修复已有文件的权限（ACL），以及统一未来文件的权限（default ACL，关键）
含义：
> 以后在 `/share` 中创建的任何文件或目录，  
> `share` 组始终拥有 `rwx` 权限，无视创建者和 umask。
```bash
# 修复已有文件的权限（ACL）
setfacl -R -m g:share:rwx /share
# 统一未来文件的权限（default ACL，关键）
setfacl -R -d -m g:share:rwx /share
# 统一子文件（不包含文件夹）去除setgid
find /share -type f -perm -2000 -exec chmod g-s {} +\n
```
---

---

### 5. 确保 ACL mask 不限制权限

```bash
setfacl -R -m m::rwx /share
setfacl -R -d -m m::rwx /share
```

---

### 6. （可选）防止误删文件：Sticky Bit

```bash
chmod +t /share
```

最终目录权限可能为：

```
drwxrwsr-t  root share /share
```

效果：
- 可以修改他人文件
- 不能删除他人文件（除非 root）
---

## 五、后期运维（Operations & Tips）

### 1. 快速健康检查

```bash
ls -ld /share
getfacl /share
```

关注：
- 是否存在 `s`（setgid）
- 是否存在 `default:group:share:rwx`

---

### 2. 权限异常的常见排查顺序

```bash
id 用户名           # 是否仍在 share 组
getfacl 文件名
mount | grep acl    # 文件系统是否支持 ACL
```

---

### 3. 看到 ls -l 中的 `+` 不要慌

```
-rw-rwx---+ file.txt
```

`+` 表示该文件存在 ACL，这是正常状态。

---

### 4. 一句话运维口诀

> **共享目录看 group，不看人；  
> 权限不稳用 ACL；  
> setgid 是灵魂。**

---

## 六、总结

当一个目录被多个协议访问时，权限问题几乎不可避免。  
正确的做法不是不断修补 chmod，而是：

- **统一 group**
- **用 setgid 保证继承**
- **用 ACL 覆盖 umask 差异**

一旦设计正确，后续几乎不需要维护。

**一次设计，长期省心。**

