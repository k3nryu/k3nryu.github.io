---
title: Linux edit Route Table
date: 2021/04/22 17:21:42
tags:
  - linux
  - network
  - server
categories:
  - Linux
toc: true
#sidebar: none
---

# View the current state of the routing table

## Option 1

`ip route` ![3baf970dfe2c81d10613c4c08ec4e684.png](/resources/80b8de4114fe4c59a4877741f2c323c2.png)

## Option 2

1. minimal version need to install "net-tools" package `dnf -y install net-tools`
2. type the following command and hit Enter: `netstat -rn` ![60b81f6bc6533eac152c56982f54a741.png](/resources/28f24b6d6f9645eaac8f33745e6abf99.png)

## Option 3

1. minimal version need to install "net-tools" package 
2. type the following command and hit Enter: `route` ![3c3de4a28a99508993d2814e0bf6d347.png](/resources/c3b0aeaad4e94239b283388e0252173b.png)

# Add a Static Route to the Linux Routing Table

When the add or del options are used, route modifies the routing tables. Without these options, route displays the current contents of the routing tables.

## Option 1

The target is a network `route -p add -net network-address -gateway gateway-address` Creates a route that must persist across system reboots. If you want the route to prevail only for the current session, do not use the -p option.

## Option 2

The target is a host `route -p add -host network-address -gateway gateway-address`

# Remove a Static Route from the Linux Routing Table

## Option 1

The target is a network `route -p del -net network-address -gateway gateway-address` Creates a route that must persist across system reboots. If you want the route to prevail only for the current session, do not use the -p option.

## Option 2

The target is a host `route -p del -host network-address -gateway gateway-address`

