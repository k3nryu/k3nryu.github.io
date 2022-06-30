---
title: SMART Monitoring Tools
date: 2021/12/11 12:09:02
tags:
  - linux
  - server
  - storage
categories:
  - Storage
toc: true
#sidebar: none
---

# Objectives
- Self-Monitoring, Analysis and Reporting Technology.
- Logging SMART errors and changes via the SYSLOG interface.
- Send email warnings if problems are detected.
- Make HDD enclosure LED blinking.

# Descriptions
## smartmontools
smartctl controls the Self-Monitoring, Analysis and Reporting Technology (SMART) system built into most ATA/SATA and SCSI/SAS hard drives and solid-state drives. The purpose of SMART is to monitor the reliability of the hard drive and predict drive failures, and to carry out different types of drive self-tests. smartctl also supports some features not related to SMART. This version of smartctl is compatible with ACS-3, ACS-2, ATA8-ACS, ATA/ATAPI-7 and earlier standards (see REFERENCES below).
## ledmon
The ledctl is an user space application designed to control LEDs associated with each slot in an enclosure or a drive bay. The LEDs of devices listed in list_of_devices are set to the given pattern pattern_name and all other LEDs are turned off. User must have root privileges to use this application.

# Installation
Install SMART monitor tool and set it to start automatically when OS start-up.
```
dnf -y install smartmontools
systemctl enable --now ledmon.service
```
Install LED's controller tool and set it to start automatically when OS start-up.
```
dnf -y install ledmon
systemctl enable --now smartd.service
```
# Configuration
## smartmontools

Send Error massege via SMTP
```
vim /etc/smartmontools/smartd.conf

# Specify SMTP server and accounds.
```
# Maintenance
> Note: Not recommented to use /dev/sdX to specify HDD.
```
smartctl --scan
smartctl /dev/sda -i
```
The following example illustrates how to locate a single block device.
```
ledctl locate=/dev/disk/by-id/wwn-0x5000039b0810bcd9
```
The following example illustrates how to turn Locate LED off for the same block device.
```
ledctl locate_off=/dev/disk/by-id/wwn-0x5000039b0810bcd9
