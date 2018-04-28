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

3.2 调用`HDLCommand.shareInstance.devicesSearch(delegate: self)`获取HDL设备数据。必须实现接口`DevicesInfoDelegate`，接收方法为：`getDevicesData(searchDevicesBackInfo: SearchDevicesBackInfo)`

3.3 调用`HDLCommand.shareInstance.scenesSearch(delegate: self)`获取HDL场景数据。必须实现接口`ScenesInfoDelegate`，接收方法为：`etScenesData(searchDevicesBackInfo: SearchDevicesBackInfo)`


### 4：获取设备信息
在搜索中获取到信息为设备信息，在demo中的ApplianceVC显示设备信息。设备信息列表显示的是此设备所有回路设备。 如果需要确定哪个设备哪个回路，则可通过子网id和设备id，大类，小类，回路号。具体可查看CtrlVC。

4.1：必须先注册委托：`HDLCommand.shareInstance.registerDelegate(delegate: self,type: HDLApConfig.TYPE_LIGHT)`根据设备类型不同注册不同委托，设备状态改变时会接收到相关推送。详情请查看Demo。

4.2：通过`info!.deviceType!` 可获取设备类型参数。info为固定值，具体查看Demo CtrlVC获取。设备类型列表以及具体数值：
```
        // 101：调光回路（灯） 102：开关回路（继电器）（灯） 103：混合调光类 （灯） 104：混合开关类（继电器）（灯）
        // 201：开合帘电机（窗帘）202：卷帘电机（窗帘） 203：窗帘模块 （窗帘）
        // 301：HVAC 模块(空调)   302：通用空调面板(空调)
        // 401：背景音乐模块（音乐） 402：第三方背景音乐模块（音乐）
        // 501：逻辑模块（场景） 502：全局逻辑模块（场景）
        
        //101，102，103，104 为灯 TYPE_LIGHT_DIMMER、TYPE_LIGHT_RELAY、TYPE_LIGHT_MIX_DIMMER、TYPE_LIGHT_MIX_RELAY
        //201，202，203 为窗帘 TYPE_CURTAIN_GLYSTRO、TYPE_CURTAIN_ROLLER、TYPE_CURTAIN_MODULE
        //301，302，303 为空调 TYPE_AC_HVAC、TYPE_AC_PANEL
        //401，402 为音乐 TYPE_MUSIC_MODULE、TYPE_MUSIC_THIRD_PARTY_MODULE
        //501，502 为场景 TYPE_LOGIC_MODULE、TYPE_GLOBAL_LOGIC_MODULE

```




### 5 获取相关设备状态
5.1：获取设备状态方法：`HDLCommand.shareInstance.getDeviceState(delegate: self, appliancesInfo: self.info!)` 第一个参数为委托参数，第二个参数为固定参数。

5.2：必须实现的委托：`DeviceStateDelegate` 分别为灯光、窗帘、空调、获取设备状态、场景，委托。

5.3：返回的方法为：`getDevicesState(devicesStateBackInfo: DevicesStateBackInfo)`具体使用请查看Demo。


### 6 控制设备
所有SDK目前支持的控制设备类型，都具有超时操作反馈，若在5秒内设备无返回控制成功消息，则SDK会返回控制超时的信息。

#### 6.1灯光控制

6.1.1 灯光控制调用`HDLCommand.shareInstance.lightCtrl(delegate: self, appliancesInfo: self.info!, state: lightState)`第三个参数为灯光亮度。继电器类型0代表关，100代表开。调光类型：范围在0-100.超过100不做处理。


6.1.2：必须实现的协议：`LightCtrlDelegate` 。

6.1.3：灯光控制返回方法：`getLightCtrlInfo(lightCtrlBackInfo: LightCtrlBackInfo)`。具体接收使用请查看Demo

#### 6.2 窗帘控制
窗帘种类有：窗帘模块，卷帘电机，开合帘电机。

6.2.1:窗帘控制调用`HDLCommand.shareInstance.curtainCtrl(delegate: self, appliancesInfo: self.info!, state: CurtainCtrlParser.shareInstance.curtainPause)` 为控制窗帘暂停。第二个参数为窗帘状态参数分别有：`CurtainCtrlParser.shareInstance.curtainClose，CurtainCtrlParser.shareInstance.curtainOpen，CurtainCtrlParser.shareInstance.curtainPause`，均可以使用这3个参数控制窗帘关、开、停。

6.2.2:若为卷帘电机、开合帘电机则还可以调用百分比方法打开具体开合度。`HDLCommand.shareInstance.curtainCtrl(delegate: self, appliancesInfo: self.info!, state: 50)`第二个参数为百分比开合度。注意：窗帘模块不具有此方法。

6.2.3：必须实现的协议：`CurtainCtrlDelegate` 

6.2.4：窗帘控制返回方法：`getCurtainCtrlInfo(curtainCtrlBackInfo: CurtainCtrlBackInfo)`

#### 6.3空调控制
6.3.1 空调控制方法如下所示：
```
        //以下为具体控制空调的api。注意：当空调模式为抽湿时，不能调节风速。当空调模式为通风时，不能调节温度。
        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airSwich, state: AirCtrlParser.shareInstance.airOn) //空调开
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airSwich, state: AirCtrlParser.shareInstance.airOff)//空调关
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airSpeed, state: AirCtrlParser.shareInstance.airSpeedAuto)//风速自动
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airSpeed, state: AirCtrlParser.shareInstance.airSpeedHigh)//风速高风
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airSpeed, state: AirCtrlParser.shareInstance.airSpeedMid)//风速中风
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airSpeed, state: AirCtrlParser.shareInstance.airSpeedLow)//风速低风
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airMode, state: AirCtrlParser.shareInstance.airModeRefTem)//空调模式制冷
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airMode, state: AirCtrlParser.shareInstance.airModeHeatTem)//空调模式制热
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airMode, state: AirCtrlParser.shareInstance.airModeVen)//空调模式通风
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airMode, state: AirCtrlParser.shareInstance.airModeAuto)//空调模式自动
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.airMode, state: AirCtrlParser.shareInstance.airModeDehum)//空调模式抽湿
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.heatTem, state: 28)//制热温度 范围0-30
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.autoTem, state: 20)//自动温度 范围0-30
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.refTem, state: 16)//制冷温度 范围0-30
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.dehumTem, state: 20)//抽湿温度 范围0-30
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.upTem, state: 1)//上升温度 范围0-5
        //        HDLCommand.shareInstance.airCtrl(delegate: self, appliancesInfo: self.info!, ctrlType: AirCtrlParser.shareInstance.downTem, state: 1)//下降温度 范围0-5

```

6.3.2:空调必须实现的协议：`ACCtrlDelegate`

6.3.3:空调控制返回的方法：`getAirCtrlInfo(airCtrlBackInfo: AirCtrlBackInfo)`

#### 6.4 场景模块控制

6.4.1:场景控制调用`getSceneCtrlInfo(sceneCtrlBackInfo: SceneCtrlBackInfo)`

6.4.2:场景必须实现的协议：`SceneCtrlDelegate`

6.4.3：场景控制返回的方法：`getSceneCtrlInfo(sceneCtrlBackInfo: SceneCtrlBackInfo)`场景控制没有状态











