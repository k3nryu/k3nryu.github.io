---
title: Storage Benchmark (fio command)
date: 2021/04/08 14:40:00
tags:
  - linux
  - server
  - storage
categories:
  - Storage
toc: true
#sidebar: none
---

```
# 顺序写：
fio -filename=/dev/md -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=8M -size=60G -numjobs=64 -runtime=10 -group_reporting -name=file
# 顺序读：
fio -filename=/dev/md -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=8M -size=60G -numjobs=64 -runtime=10 -group_reporting -name=file
# 随机写：
fio -filename=/dev/md -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=8M -size=60G -numjobs=64 -runtime=10 -group_reporting -name=file
# 随机读：
fio -filename=/dev/md -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=8M -size=60G -numjobs=64 -runtime=10 -group_reporting -name=file
# 混合随机读写：
fio -filename=/dev/md -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=30 -ioengine=psync -bs=8M -size=60G -numjobs=64 -runtime=10 -group_reporting -name=file -ioscheduler=noop
# 当目标为Directory的时候
fio -directory=/mnt/ -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=8M -size=60G -numjobs=64 -runtime=10 -group_reporting -name=file
```

```shell
umount -l 10.0.1.2:/mnt/nas/nas
mount -t nfs 10.0.1.2:/mnt/nas/nas /mnt
mount -t nfs -o nolock,timeo=15 10.0.1.2:/mnt/nas/nas /mnt
mount -t nfs 10.0.1.2:/mnt/nas/nas /mnt -o nolock, rsize=1024,wsize=1024,timeo=15
mount -t nfs -o rsize=131072,wsize=131072 10.0.1.2:/mnt/nas/nas /mnt
```

