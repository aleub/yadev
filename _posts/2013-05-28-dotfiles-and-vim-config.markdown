---
layout: post
title: "Dotfiles and my .vimrc config"
date: "2013-05-28 00:00:00"
---
# Dotfiles
Since a colleague of mine always asks about my current vim config, i updated my dotfiles repository on github [here](https://github.com/leubnerandre/dotfiles). Those include my vimrc, .vim, zshrc, Xresources and screenrc. 

To get it working, first you should move your own files to a safe place. If you want to change stuff the way you want it, fork the repo. Then clone youre own, or my repo, cd into the newly created repo and install them:

```bash
cd ~
git clone https://github.com/leubnerandre/dotfiles
cd dotfiles
make install
make update
```

Using this method youre keeping all your config files in a convenient place, just pointing to them using symlinks. The last command is a oneline makefile entry which runs git pull in every directory in ~/.vim/bundle, that fetches the most recent git version from each vim plugin. If you havn't noticed already, i'm managing my plugins via [pathogen](https://github.com/tpope/vim-pathogen), it's neat to put your newly discovered vim plugin in the bundle folder and your good to go. However, i should mention there is a better way of using vim plugins in your personal dotfiles, which is adding them through git submodules, but i couldnt figure it out when i did this setup and this solution works aswell.

# .vimrc

I realized the vimrc file is quite well commented, no need to go through every line. The original file is not written by me, however i dont remember where i found it.

Take a look at [my vimrc here](https://github.com/leubnerandre/dotfiles/blob/master/vimrc).

In combination with urxvt ( + nice Xresources) it provides you with this eyecandy:

![vim in urxvt](/media/vim-2013-05-28-003537_742x814_scrot.png "vim in urxvt")
