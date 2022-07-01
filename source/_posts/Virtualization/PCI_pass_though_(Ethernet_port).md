---
title: PCI pass though (Ethernet port)
date: 2021/08/26 15:51:28
tags:
  - kvm
  - hypervisor
categories:
  - Virtualization
toc: true
#sidebar: none
---

```
ifconfig
```
![58d2fbc072f3f7bf1ce2a499b5351171.png](/resources/1b17f06e0c5e4b5f874e8d75f202e0a3.png)
```
[root@SMC-KVM ~]# ethtool -i eno2
driver: ixgbe
version: 4.18.0-305.10.2.el8_4.x86_64
firmware-version: 0x800007f6, 1.1747.0
expansion-rom-version:
bus-info: 0000:01:00.1
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes
```
![3211af94caf301c7b3f8e2c6733a0a41.png](/resources/27aace41d26041b79a0f5d80136e96e9.png)

```
# vim /etc/grub2-efi.cfg
# vim /etc/grub2.cfg
set kernelopts="...iommu.passthrough=1"

```
![9ab23b9c1a1cf4a1a7c3112cf9b149c7.png](/resources/98a5588d33c6466885873b358a593124.png)

Enable intel iommu:
```
vim /etc/default/grub

GRUB_CMDLINE_LINUX="... intel_iommu=on iommu=pt
#GRUB_CMDLINE_LINUX=" ... amd_iommu=on
```
> If intel_iommu=on or amd_iommu=on works, you can try replacing them with iommu=pt or amd_iommu=pt.


```
grub2-mkconfig -o /boot/grub2/grub.cfg
cat /etc/grub2.cfg | grep 'set kernelopt' # 这时候上面的设置已经被映射过来了
reboot
```

```
dmesg | grep IOMMU
```
![c7a7c4f84766890e7a208a172e89536f.png](/resources/ccce25e9c35147de801cf73e4dad14bd.png)


Modify VM's specification:
```
cp /etc/libvirt/qemu/cjl-test.xml /etc/libvirt/qemu/cjl-test.xml.bak
vim /etc/libvirt/qemu/cjl-test.xml
```

```
<hostdev mode='subsystem' type='pci' managed='yes'>
<source>
<address domain='0x0000' bus='0x01' slot='0x00' function='0x1'/>
</source>
##<address type='pci' domain='0x0000' bus='0x01' slot='0x02' function='0x0'/>
</hostdev>

```
![b78244be8645b79ac8943a0048b30856.png](/resources/8bef6e49dd35419e87752e04ca76910f.png)

```
virsh define &VMname
```

```
ethtool -i eno2
ethtool -i eno1
```


# Guest (VM)

![287e347b89b51b80dd46d4a9d1e9651c.png](/resources/908b43347b8f434da7ed603cdabb2206.png)

```
[root@localhost ~]# lspci | grep Ethernet
00:02.0 Ethernet controller: Intel Corporation Ethernet Controller 10G X550T (rev 01)
```

```
[root@localhost ~]# ethtool -i ens2
driver: ixgbe
version: 4.18.0-305.10.2.el8_4.x86_64
firmware-version: 0x800007f6, 1.1747.0
expansion-rom-version:
bus-info: 0000:00:02.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes
```
