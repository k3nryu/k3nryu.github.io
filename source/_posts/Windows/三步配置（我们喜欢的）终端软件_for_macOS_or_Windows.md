---
title: 三步配置（我们喜欢的）终端软件 for macOS/ Windows
date: 2025/12/17 20:30:30
tags:
  - windows
  - macOS
  - git
  - blog
  - shell
  - zsh
  - console
categories:
  - macOS
toc: true
#sidebar: none
---

## 大概思路
1. 安装依赖
2. 配置Git/GitHUB
3. 从GitHub克隆Dotfiles

## Step1. 安装依赖
### 下载我们喜欢Console软件
随意选择你喜欢的：
MacOS：iTerm2，alacrrity，Tabby，etc。
Windows：Terminal，TeraTerm，etc。
### Zsh
- Oh-my-zsh(zsh manager)
- Powerlevel10k(zsh theme)
- Zsh-syntax-highlighting
- Zsh-autosuggestions
### Nerd Font
- [MesloLGS NF](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k) (Install on your OS and set terminal emulator font for powerlevel10k theme)

## Step2. 配置Git/GitHub
登陆GitHUB
```
ssh -T git@github.com
```
Before
![ssh_test_before.png](/resources/ssh_test_before.png)
After
![ssh_test_after.png](/resources/ssh_test_after.png)

在设置git的用户名&邮箱账号
```
git config --global user.name "k3nryu"
git config --global user.email "tinkenryu@gmail.com"
```
本机上生成一对公开密钥，之后我们把公钥放进个人GitHub的账户里，告诉GitHub这台机器是自己人，从而可以进行ssh协议的各项操作。
```
ssh-keygen -C "tinkenryu@gmail.com"
cat .ssh/id_rsa.pub
```
登录我们的Github账号，并粘贴上面的公钥。   
https://github.com/settings/keys   
确认能不能通过ssh连上GitHub的服务器
```
ssh -T git@github.com
```

## Step3. 从GitHub克隆Dotfiles
Clone repositories to local.
```bash
git clone --recursive -b macOS git@github.com:k3nryu/dotfiles.git
```
Execute 'install.sh' shell script.
```bash
docfiles/install.sh
```

## Update
```bash
# git拉取远程到本地
git status
git pull origin main/ master/ develop

# (Option/Recommand)创建分支
git checkout -b bugfix/xxx
git checkout -b feature/yyy
git checkout -b forZZZ/zzz

# 本地编辑Dotfiles
vim xxx

# 查看改了什么
git diff

# 分段提交
git add .
git commit -m "Fix few Bugs"
#一次commit只做一件事情（Fix/Add/Updata/Refactor）

# 同步主分支
git fetch origin #
git rebase origin/main
or 
git merge origin/main

# 推送远端分支
git push origin feature/yyy
```

## Uninstall
```bash
rm -rf ~/dotfiles
rm -rf ~/.oh-my-zsh
```

