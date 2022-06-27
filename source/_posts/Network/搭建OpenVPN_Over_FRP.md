---
title: 搭建OpenVPN Over FRP
date: 2021/10/31 14:08:47
tags:
  - linux
  - network
  - vpn
categories:
  - Network
toc: true
#sidebar: none
---

# 前言
在学校或者公司外部的，或者出差在外地，想访问学校或者公司内网的服务器，但是没用网络管理员的权限，或者网络管理员不配合设定的情况下，如何突破NAT网络防火墙，达到访问内部网络。这是搭建这个服务的目的。

关于frp
> A fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet. https://github.com/fatedier/frp

它是一个反向代理程序。它可以将借助存在于公网上的代理服务器，中继 NAT 和防火墙后面的服务，实现内网穿透（NAT Traversal、ファイアウォール透過＆貫通）的一种手段。

![Openvpn over frp.png](/resources/eade905969e34b7f9deed26d8a9c6dd0.png)


在接下来搭建好的Proxy服务器中，sockstat命令（摘录；考虑隐私公网IP随便写的）中可以了解到：
```
[2.5.2-RELEASE][root@Proxy]/root: sockstat | grep frp

# 监听7000端口
root frps 67615 3 tcp46 *:7000 *:*
# 在内网的Proxy Server经过路由NAT转换之后的公网IP与Proxy Server进行了连接
root frps 67615 11 tcp4 110.120.119.1:7000 119.120.110.1:61662
# 监听6000端口（SSH服务）
root frps 67615 10 tcp46 *:6000 *:*
# 接受了客户端的连接
root frps 67615 14 tcp4 110.120.119.1:6000 192.168.10.10:68623
# 监听1194端口（OpenVPN服务）
root frps 67615 9 tcp46 *:1194 *:*

```
Client与Proxy建立连接，Reverse Proxy也与Proxy建立连接，通过这种围魏救赵的方式实现Client与Reverse Proxy建立连接。


以下是使用frp反向代理openvpn突破防火墙的一个demo。

# 0. demo环境

| Host | OS | Service | IP | Allow Port (Inbound) |
| --- | --- | --- | --- | --- |
| Reverse Proxy Server | CentOS Linux release 8.4.2105 | frpc (frp_0.38.0_linux_amd64), openvpn | P:172.16.10.10 (G:119.120.110.1) | / |
| Proxy Server | FreeBSD 12.2-STABLE | frps (frp_0.38.0_freebsd_amd64) | 110.120.119.1 | #7000(from RPS) & #6000(from client) & #1194(from client)|
| Client | macOS | openvpn-client | 192.168.10.10 | / |

*OS基本可以无视，因为不管是frp或者OpenVPN基本全平台适配*


# 1. 部署Reverse Proxy Server
在想要突破的内网环境（公司，学校）的机器上安装必要的frp，和其他服务这里用openvpn演示。防火墙策略允许outbound。

## 1.1 部署frpc
目前可以在 Github 的 Release 页面中下载到最新版本的二进制文件。 https://github.com/fatedier/frp/releases/

```
wget https://github.com/fatedier/frp/releases/download/v0.38.0/frp_0.38.0_linux_amd64.tar.gz

```

## 1.1.1 解压安装包

解压缩下载的压缩包， 放置在任意目录。

```
tar -zxvf frp_0.38.0_linux_amd64.tar.gz
cd frp_0.38.0_linux_amd64
```
> 这里（Reverse Proxy Server）上只用到frpc相关的文件，frps用不到。

## 1.1.2 配置以及启动服务
```
[root@ServerC /]# cat frpc.ini
[common]
server_addr = 110.120.119.1 # Proxy Server的公网IP
server_port = 7000 # Proxy Server上的frps监听frpc连接的端口

[ssh]
type = tcp
local_ip = 127.0.0.1 # 指向本机IP
local_port = 22 # 指向本机的SSH端口
remote_port = 6000 # Proxy Server监听的端口。之后Client可以通过访问Proxy Server的6000端口，端口转发到上面的本机端口
```

通过 ` ./frpc -c ./frpc.ini &` 启动服务端。
```
[root@cjl-docker frp_0.37.1_linux_amd64]# ./frpc -c ./frpc.ini
2021/08/25 00:00:40 [I] [service.go:304] [a0e6112664ab2527] login to server success, get run id [a0e6112664ab2527], server udp port [0]
2021/08/25 00:00:40 [I] [proxy_manager.go:144] [a0e6112664ab2527] proxy added: [ssh]
2021/08/25 00:00:40 [I] [control.go:180] [a0e6112664ab2527] [ssh] start proxy success
```
如果需要在后台长期运行，建议结合其他工具使用，例如 systemd 和 supervisor。

## 1.1.3 部署openvpn
这里不做演示了，详细请参阅搭建openvpn教程。
> [如何在 CentOS 8 上设置和配置 OpenVPN 服务器
](https://www.gingerdoc.com/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-centos-8)

# 2. 搭建Proxy Server
在用有公网IP的机器安装frps服务，设定好防火墙。
这里用的是FreeBSD，公网IP为110.120.119.1，防火墙策略为：允许来自Reverse Proxy Server公网IP的连接，和允许来自Client的连接。

## 2.1 下载安装包

目前可以在 Github 的 Release 页面中下载到最新版本的客户端和服务端二进制文件，所有文件被打包在一个压缩包中。 https://github.com/fatedier/frp/releases/tag/v0.37.1

```
wget https://github.com/fatedier/frp/releases/download/v0.37.1/frp_0.37.1_linux_amd64.tar.gz
```

## 2.2 解压安装包

解压缩下载的压缩包，放置在任意目录。

```
tar -xzvf frp_0.37.1_linux_amd64.tar.gz
```
> Proxy只用到frps。

## 2.3 配置文件以及启动服务
编写配置文件
```
cat frp_0.37.1_linux_amd64/frps.ini
---
[common]
bind_port = 7000
```

通过 ` ./frps -c ./frps.ini &` 启动服务端，之后再通过 `ss -ntul` 查看是否开启监听7000端口。如果需要在后台长期运行，建议结合其他工具使用，例如 systemd 和 supervisor。

## 2.4 配置防火墙
- 策略1：让Proxy的7000端口暴露在公网上，才能让Reverse Proxy经行握手连接。
- 策略2：6000端口要暴露给Client。

> 具体设置的话要根据情况不同，如果Proxy或者Client也经过NAT，路由或者防火墙的话，除了本机防火之外，路由器的防火墙也要设定。

# 3. 测试以及使用
## 3.1 开启服务后进行端口扫描：
先开启frps，再开启frpc。当frpc连接上frps的时候，frps的6000号端口才会开启了监听。
### 方法1
在线端口扫描
https://www.cman.jp/network/support/go_port.cgi
### 方法2
通过nmap工具端口扫描
```
nmap -p 7000 110.120.119.1
nmap -p 6000 110.120.119.1
```
## 3.2 开始使用
Server A或者任意设备通过SSH访问Server B的6000端口，即可转发到Server C的22端口！
```
ssh 110.120.119.1 -p 6000
```

# 总结
内网服务器上部署frpc服务（可以设置为systemctl开机自启），与reverse proxy服务器frps建立握手连接，通过SSH访问frps的端口转发，最终达到访问frpc所在服务器的目的。

# 参考
>

