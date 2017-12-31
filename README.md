# RHPlayer
![](https://github.com/RailgunHamster/RHPlayer/blob/master/NewRHPlayer/Screenshots/app.png)

151220114 王宇鑫
***
## 概述
RHPlayer是一款多格式的播放器（虽然我没实现几种），足够我日常使用
- 简易的用户文件系统
- 重命名与删除
- zip压缩文件直接访问
- 视频播放
- 图片滑动浏览
- 记录用户历史访问
***
## 界面
### 1、用户文件界面：
在这个界面单击文件即可打开文件，zip文件和文件夹会展示内部（需要密码时会询问），而其他支持格式的文件则会直接打开。

![](https://github.com/RailgunHamster/RHPlayer/blob/master/NewRHPlayer/Screenshots/主界面.png)

浏览图片的界面：
这是在浏览文件夹内的图片时的界面，左右滑动可以直接切换图片，下方也可以跳转图片，单击隐藏本界面。

![](https://github.com/RailgunHamster/RHPlayer/blob/master/NewRHPlayer/Screenshots/图片.png)
### 2、浏览记录：
最近访问的文件会按照时间顺序排列，并将日期时间显示在下方。
右上角清空。
由coredata实现存储。

![](https://github.com/RailgunHamster/RHPlayer/blob/master/NewRHPlayer/Screenshots/最近浏览.png)
### 3、设置界面：
在用户文件界面点击右上角，即可打开设置界面。

![](https://github.com/RailgunHamster/RHPlayer/blob/master/NewRHPlayer/Screenshots/设置.png)
## 其他
1. 长按进入文件详细页面，可以对文件进行重命名、删除操作，也可以打开文件。
1. 在浏览记录界面长按，可以打开该文件所在的文件夹。
## 不足
1. 支持格式稍少
1. 界面不够美观
## 统计
不计空格，2284行
## 说明
- 由cocoapods做第三方管理
- 使用第三方库SSZipArchive对zip文件进行处理
