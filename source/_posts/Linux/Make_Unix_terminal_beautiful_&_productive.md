---
title: Make Unix terminal beautiful & productive
date: 2022/05/25 13:12:17
categories:
  - Linux
toc: true
#sidebar: none
---

![iShot_0004-06-30_21.30.44.gif](/resources/c64efe2ef23a48c9916d40d47ddedbcb.gif)

First of all, check the activated shell using this command.
```
echo $SHELL
```
The below command will display all the available shell.
```
cat /etc/shells
```
## Install ZSH
```
dnf -y install zsh
# If chsh command no found :
dnf -y install util-linux-user
```
## change shell
```
chsh -s $(which zsh)
```
## Install Oh-My-ZSH
```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# or
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
# or
curl -Lo install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

```

## Install powerlevle10k theme
```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/oh-my-zsh/themes/powerlevel10k
echo 'source ~/oh-my-zsh/themes/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

```
Execute `vim .zshrc` and modify `ZSH_THEME="powerlevel10k/powerlevel10k" `

https://github.com/romkatv/powerlevel10k#installation

## Specify Terminal Tab title on ZSH
Execute `vim .zshrc` add following.
```
# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# To display Hostname😎PWD_Name as title text
HOSTNAME=$(hostname -s)

# Let zsh launch with the custom title.
window_title="\033]0;$HOSTNAME😎${PWD##*/}\007"
echo -ne "$window_title"
# Refresh the custome title when the directory changes. Changed from precmd as it shall suppress the set-title function below
function chpwd () {
window_title="\033]0;$HOSTNAME😎${PWD##*/}\007"
echo -ne "$window_title"
}
# Setting your own title text on demand. (Don't change dir after setting it 😎)
function set-title(){
TITLE="\[\e]2;$*\a\]"
echo -e ${TITLE}
}
```
