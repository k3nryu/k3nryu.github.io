---
title: ZFS常用命令
date: 2022/02/28 15:52:32
tags:
  - Server
  - ZFS
  - Storage
categories:
  - ZFS
toc: true
#sidebar: none
---

# 1. 创建pool和ZFS文件系统

- 创建名为 “tank” 的存储池 (type: ,mirror,raidz,raidz2,raidz3)
```
# zpool create tank <type> sdb sdc sdd sde
```
> 注意： Linux的大多数情况下，sda，sdb，sdc并没有按照slot的顺序排列，是乱序的。
```
find -L /dev/disk/by-id -samefile /dev/sda
```
- 向池中添加更多空间
> 池(pool)中的其他空间(vdev)要相同type，相同数量。否则出现"mismatched replication level"错误。
```
# zpool add tank mirror sdf sdg
```

- 创建文件系统，挂载在 /export/home 下
```
# zfs create tank/home
# df -Th
# zfs set mountpoint=/export/home tank/home
```
- 为多个用户创建起始目录
t> 请注意：由于继承而自动挂载在 /export/home/{ahrens,bonwick,billm} 下
```
# zfs create tank/home/ahrens
# zfs create tank/home/bonwick
# zfs create tank/home/billm
```

- 修改文件系统名称
```
# zfs rename tank/home/ahrens tank/home/nahrens
```
- 删除文件系统
```     
# zfs destroy -Rf tank/fs
```
- 修改存储池的名称
```
# zpool export tank

# zpool import tank newpool
```
# 2. 设置属性

- 自动以 NFS 方式共享该文件系统
```
# zfs set sharenfs=rw tank/home
```
- 对文件系统中所有数据启用压缩
```
# zfs set compression=on tank
```
- 将用户 A的最大空间限制为 10g
```
# zfs set quota=10g tank/home/userA
```
- 保证用户 B有 20g 的预留空间
```
# zfs set reservation=20g tank/home/userB
```
- 可通过命令查询文件系统的所有属性
```
# zfs get all tank/home
```
- 可通过命令查询存储池的所有属性
```
# zpool get all tank
```
- 大多数属性可通过继承方式自动设置 
```
# zfs inherit <property> tank/home/eschrock
```

# 3. ZFS snapshot

- 文件系统的只读副本
即时创建、数量不限,不占用额外空间 \- 块仅在发生更改时才会被复制
可通过每个文件系统根目录下的 .zfs/snapshot 访问
使用户可在没有系统管理员介入的情况下恢复文件
对用户Ａ 的起始目录执行快照捕获
```
# zfs snapshot tank/home/usera@tuesday
```
- 回滚到前一个快照
```
# zfs rollback tank/home/usera@monday
```
- 查看星期三的 foo.c 版本
```
$ cat /tank/home/usera/.zfs/snapshot/wednesday/foo.c
```
- 删除快照
```
# zfs destroy -R tank/home/usera@monday
```
# 4. ZFS Clone

- 快照的可写副本
即时创建、数量不限
存储大部分为共享数据的众多专用副本的理想方法
软件安装
工作区
无盘客户机

- 创建 OpenSolaris 源代码的克隆
```
# zfs clone tank/solaris@monday tank/ws/lori/fix
```
# 5. ZFS send/receive

- 基于快照点
完整备份：任何快照
增量备份：任何快照增量
速度很快 \- 开销与更改的数据成比例
非常高效，可执行远程复制

- 生成完整备份
```
# zfs send tank/fs@A >/backup/A    
```
- 生成增量备份
```
# zfs send -i tank/fs@A tank/fs@B >/backup/B-A
```
- 远程复制：每分钟发送一次增量
```
# zfs send -i tank/fs@11:31 tank/fs@11:32 | ssh host zfs receive -d /tank/fs
```
# 6. ZFS 数据迁移

- 独立于主机的磁盘格式
将服务器从 x86 更改为 SPARC，也能运行
自适应字节存储顺序 (Adaptive endianness)：在两个平台上都无需额外成本
写入总是使用本地字节存储顺序 (native endianness)，在块指针中设置位
仅当主机字节存储顺序 (endianness) != 块字节存储顺序时，才会针对读取进行字节交换
 

- ZFS 负责所有处理
无需考虑设备路径、配置文件、/etc/vfstab 等等
ZFS 会在必要时进行共享/取消共享、挂载/取消挂载等等

- 从旧服务器上导出池tank
```
old# zpool export tank
```

- 物理移动磁盘并将池导入到新服务器中
```
new# zpool import tank
```
# 7. 设备管理

- 添加/替换新设备 (type: ,mirror,raidz,raidz2,raidz3)
```
# zpool add tank <type> c0t2d0 c0t3d0 c0t4d0

# zpool replace tank c0t1d0 c0t2d0
```

- 添加/移除镜像设备
```
# zpool attach tank c0t1d0 c0t2d0
# zpool detach tank c0t2d0
```

- 将设备停止或手工启动 
```
# zpool offline tank c0t2d0
# zpool online tank c0t2d0
```

- 查看存储池当前状态和 I/O 状况
```
# zpool status -v tank
# zpool iostat tank 1
```
- 添加热备设备
```
# zpool add tank spare c0t2d0
```

- 指定热备启动/停止热备
```
# zpool replace tank c0t1d0 c0t2d0
# zpool detach tank c0t2d0
```

- 将热备设备删除
```
# zpool remove tank c0t2d0
```

- 添加/删除独立的日志设备（性能改善）
```
# zpool add tank log c0t3d0
# zpool remove tank c0t3d0
```
# 8. ZFS 权限管理

- 可以将zfs(1M) 的管理权限分派给普通用户
```
      'zfs allow'
      'zfs unallow'
```
- 将权限授予一个普通用户
```
# zfs allow marks create,snapshot tank/marks
```

- 将指定权限回收
```
# zfs unallow marks create,snapshot tank/marks
```

- 查看文件系统当前的权限
```
# zfs allow tank/marks
```
# 9. 其它命令

- 显示存储池所有操作历史记录
```
# zpool history tank
```
- 升级存储池到指定 SPA 版本
```
# zpool upgrade -V <version> tank
```
- 升级文件系统到指定 ZPL 版本
```
# zfs upgrade -V <version> tank/fs
```
- 手工挂载/卸载文件系统
```
# zfs mount -a
# zfs unmount tank/fs
# zfs unmount -a
```

# 参考
1. [ZFS常用命令](https://chegva.com/1337.html)
