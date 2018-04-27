# HDL iOS SDK通讯协议对接文档
这个例子是为了演示HDL的iOS SDK，可以实现搜索设备、控制设备、获取设备状态、接收设备状态改变推送等。目前支持继电器、调光灯、窗帘模块、开合帘、卷帘、空调面板、场景类型。

# 版本更新
#### v0.1.0
1：此版本为初步测试后的Beta版本，后续将发布稳定版1.0.0版本。方法名、参数等不会有大改动，可根据Demo对接相关接口。

#  How do I use it?

## Step 1

#### 下载SDK

1.目前仅支持Demo上的下载SDK，依赖到项目中使用。后续增加更多依赖方式。

2.SDK为Swift语言编写，相关公开接口方法已开放OC调用。

## Step 2：SDK初始化

1：`HDLManager.shareInstance.initSDK()`

2： SDK初始化的端口为6000，若有其他程序占用6000端口，则SDK无法初始化。将导致程序一直无法正常工作。请务必保证进程只运行一个6000端口的程序

## Step 3 调用相关API

### 3：搜索设备

3.1 HDL SDK提供搜索设备的api，稍等数秒返回设备信息。

3.2 调用`HDLCommand.shareInstance.devicesSearch(delegate: self)`获取HDL设备数据

3.3 调用`HDLCommand.shareInstance.scenesSearch(delegate: self)`获取HDL场景数据
