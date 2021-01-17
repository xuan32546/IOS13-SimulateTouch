# IOS13-SimulateTouch V0.0.6

一个**系统级**的模拟触摸库，适用于iOS 11.0 - 14

需要先对iOS设备进行越狱。应用程序级触摸模拟库[PTFakeTouch](https://github.com/Ret70/PTFakeTouch)。可根据你的需要选择。

Discord: https://discord.gg/acSXfyz

给我个star吧！！！求求了

其他语言版本: [English](README.md)


## 简介
这个**开源，永久免费的**库作为一个iOS底层与应用层的桥梁，实现iOS11 - 4的模拟触摸。在应用层一行代码即可进行模拟点击，简洁方便（下文会有代码案例）。并且支持所有编程语言编写的应用层脚本或应用程序。同时，本库支持实时控制，0延迟控制你的iOS设备。

## 脚本作者招募
如果你对制作脚本并出售感兴趣，请在Discord上面联系我。虽然ZXTouch是一个免费的软件，脚本作者依然可以对他们的脚本收取费用。

## 特性
* 模拟触控
	* 支持多指触控（这是唯一一个支持多指同时触控的库）
	* 可编程。支持任何编程语言，包括Python, C, C++, Objective-c, Java等等
	* 实时控制模式。可在电脑/平板/其他手机实时操控iOS设备
	* 系统级别模拟。无需注入到任何程序
	* 触摸录制
* App界面
* 其他
	* 前台应用程序切换
	* 系统级消息弹窗
	* Unix命令行命令执行
	*  屏幕RGB颜色选取
	*  屏幕图片匹配
	*  设备信息获取
	*  电池信息获取
	*  更多功能请看下面的文档



## 安装方法
1. 打开Cydia - 源 - 编辑 - 添加 - https://zxtouch.net （备用服务器 http://47.114.83.227 http而不是https）
2. 安装**ZXTouch**插件
3. 完成


## Demo Usage
**远程控制:**
You can control your iOS device from local scripts, computers, or even other iOS devices!
[![Watch the video](img/remote_control_demo.jpg)](https://youtu.be/gdSGO6rJIL4)

**实时控制:**
Here is a demo of PUBG Mobile.
[![Watch the video](img/pubg_mobile_demo.jpg)](https://youtu.be/XvvWHL6B3Tk)

**录制 & 播放:**
Record touch events and playback
[![Watch the video](img/record_playback.jpg)](https://youtu.be/WeYMx4z8N2M)

## 使用方法

下面有python版本的使用文档。不只是python，你可以使用**任何**编程语言去控制你的iOS设备，只要该编程语言支持socket。下面是iOS端插件的工作原理

1. 在安装后，插件会持续监听6000端口

2. 如果要控制你的设备，发送一定格式的数据到你手机的6000端口。这里不会写格式是怎样的，但是你可以查看zxtouch python模块去反推格式。


## Documentation (Python)

请看查看英文文档




## 联系我

Mail: jiz176@pitt.edu

Discord: https://discord.gg/acSXfyz


## Contact

Mail: jiz176@pitt.edu

Discord: https://discord.gg/acSXfyz
