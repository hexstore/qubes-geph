# Qubes Geph

这是一个在Qubes OS中安装迷雾通的方案，旨在帮助Qubes OS用户在严重网络审查环境下突破封锁，让Qubes OS拥有连接Tor网络的能力。

## 工作原理

它基于Qubes OS的隔离机制，将迷雾通包装成一个网络服务盒子，迷雾通被守护运行在VPN模式下，为其它应用或服务盒子提供网络。

迷雾通没有提供官方的命令行版本，这里通过编译生成适合Qubes OS运行的版本。

## 使用场景

它可以工作在这些场景下，也许您有自己的方案！

- sys-net <- sys-firewall <- **sys-geph** <- AppVM(s)
- sys-net <- **sys-geph** <- sys-firewall <- AppVM(s)

## 前提条件

- Qubes OS
- Geph(迷雾通)帐号

## 安装

这里先创建好两个盒子，它们分别用于编译和运行迷雾通，命名为`geph-builder`和`sys-geph`，`sys-geph`被配置为提供网络的服务盒子。

```bash
[user@dom0 ~]$ qvm-create geph-builder --class StandaloneVM --label black --template debian-11
[user@dom0 ~]$ qvm-volume extend geph-builder:private 5g
```

```bash
[user@dom0 ~]$ qvm-create sys-geph --class AppVM --label blue
[user@dom0 ~]$ qvm-prefs sys-geph provides_network true
[user@dom0 ~]$ qvm-prefs sys-geph autostart true
[user@dom0 ~]$ qvm-prefs sys-geph memory 500
[user@dom0 ~]$ qvm-prefs sys-geph maxmem 500
```

执行下面的指令会自动完成编译迷雾通的整个过程，最后会弹出一个复制文件的[提示窗口](./assets/qvm-copy.png)，这时需要选择目标(Target)下拉项中的`sys-geph`，以完成复制迷雾通二进制文件到`sys-geph`盒子。

```bash
[user@dom0 ~]$ qvm-start geph-builder
[user@dom0 ~]$ qrexec-client -W -d geph-builder user:'sh <(curl --proto "=https" -tlsv1.2 -sSfL https://git.sr.ht/~qubes/geph/blob/main/build.sh)'
```

接下来将完成`sys-geph`盒子的配置，这里会下载两个文件到`sys-geph`盒子，它们分别是systemd配置`geph.service`和用于管理geph服务的`geph`文件。这一步骤将会提示您输入迷雾通帐号和密码。

```bash
[user@dom0 ~]$ qrexec-client -W -d sys-geph user:'sh <(curl --proto "=https" -tlsv1.2 -sSfL https://git.sr.ht/~qubes/geph/blob/main/install.sh)'
```

来到这一步，将要重启`sys-geph`盒子。

```bash
[user@dom0 ~]$ qvm-shutdown sys-geph
[user@dom0 ~]$ qvm-start sys-geph
```

确认`sys-geph`盒子的运行状态，看到`current status: working`，说明已经成功连接迷雾通网络。

```bash
[user@dom0 ~]$ qrexec-client -W -d sys-geph root:'journalctl -fg healthcheck'
```

最后，将应用或服务盒子的`netvm`配置为`sys-geph`，以下示例将`sys-whonix`的网络配置为`sys-geph`，即`sys-geph`作为`sys-whonix`前置代理。

```bash
[user@dom0 ~]$ qvm-prefs sys-whonix netvm sys-geph
```

到这里，已经完成了迷雾通网络服务盒子的安装过程，您可以选择将`geph-builder`盒子删除。

```bash
[user@dom0 ~]$ qvm-shutdown --wait geph-builder
[user@dom0 ~]$ qvm-remove geph-builder
```

## 贡献

您在使用这个项目的过程中发现任何问题或疑问，可以随时[创建ticket](https://todo.sr.ht/~qubes/geph)，我们将会尽快解答。另外，您有任何改进方案，欢迎提交一个[patch](https://git.sr.ht/~qubes/geph/send-email)。

## 其它

对于迷雾通的安全性，我们未对它进行安全审计，还请自行权衡。

## 相关

- [Qubes OS](https://www.qubes-os.org/)
- [迷雾通网站](https://geph.io/)
- [迷雾通GitHub](https://github.com/geph-official)
- [迷雾通开发者](https://nullchinchilla.me/about.html)
