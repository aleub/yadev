---
layout: post
title: "Clipboard for SSH Connections"
date: 2013-05-23 12:17:10
---
I just found out about a nice feature to use the clipboard over remote ssh connection in linux. Just connect via `ssh -Y host.example.com`. 

To automate this you have to add the host to your ssh config file in ~/.ssh/config :

```sh
Host host.example.com
  ForwardAgent yes
  ForwardX11 yes
  ForwardX11Trused yes
```

The ForwardAgent is optional, but its nice if you use a private key with a secret and dont want to copy it to several servers.
  
