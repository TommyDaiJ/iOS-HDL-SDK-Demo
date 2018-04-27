//
//  CtrlVC.swift
//  HDLSDKDemo3
//
//  Created by Tommy on 2018/4/23.
//  Copyright © 2018年 Tommy. All rights reserved.
//

import UIKit
import HDLSDK

class CtrlVC: UIViewController,LightCtrlDelegate,CurtainCtrlDelegate,ACCtrlDelegate,DeviceStateDelegate,SceneCtrlDelegate {
    
    var info:AppliancesInfo?
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let statusBarWidth = UIApplication.shared.statusBarFrame.width
    
    let lightBtn:UIButton = UIButton(type:.system)          //灯光控制
    let lightStateLabel:UILabel = UILabel()                 //显示当前灯光的状态
    var lightState:Int = 100                                //默认值，仅用作演示。
    
    let curtainPauseBtn:UIButton = UIButton(type:.system)   //窗帘模块、卷帘、开合帘均有开关停功能演示
    let curtainOpenBtn:UIButton = UIButton(type:.system)    //窗帘模块、卷帘、开合帘均有开关停功能演示
    let curtainCloseBtn:UIButton = UIButton(type:.system)   //窗帘模块、卷帘、开合帘均有开关停功能演示
    let curtainPercentBtn:UIButton = UIButton(type:.system) //卷帘、开合帘才有此功能演示
    let curtainStateLabel:UILabel = UILabel()               //显示当前窗帘的状态
    
    let airCtrlBtn:UIButton = UIButton(type:.system)
    let airStateLabel:UILabel = UILabel()                 //显示当前空调的状态
    
    let sceneCtrlBtn:UIButton = UIButton(type:.system)      //场景控制演示
    let sceneStateLabel:UILabel = UILabel()               //场景状态演示
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        registerForHDL()
        getStateForHDL()
    }
    
    private func initView(){
        // 此处判断什么设备，并将其他设备控件隐藏
        // 1：调光回路（灯） 2：开关回路（继电器）（灯） 3：混合调光类 （灯） 4：混合开关类（继电器）（灯）
        // 5：开合帘电机（窗帘）6：卷帘电机（窗帘） 7：窗帘模块 （窗帘）
        // 8：HVAC 模块(空调)   9：通用空调面板(空调)
        // 10：背景音乐模块（音乐） 11：第三方背景音乐模块（音乐）
        // 12：逻辑模块（场景） 13：全局逻辑模块（场景）
        
        //1、2、3、4 为灯 TYPE_LIGHT_DIMMER、TYPE_LIGHT_RELAY、TYPE_LIGHT_MIX_DIMMER、TYPE_LIGHT_MIX_RELAY
        //5、6、7 为窗帘 TYPE_CURTAIN_GLYSTRO、TYPE_CURTAIN_ROLLER、TYPE_CURTAIN_MODULE
        //8、9 为空调 TYPE_AC_HVAC、TYPE_AC_PANEL
        //10、11 为音乐 TYPE_MUSIC_MODULE、TYPE_MUSIC_THIRD_PARTY_MODULE
        //12、13 为场景 TYPE_LOGIC_MODULE、TYPE_GLOBAL_LOGIC_MODULE
        switch info!.deviceType! {
        case HDLApConfig.TYPE_LIGHT_DIMMER
        ,HDLApConfig.TYPE_LIGHT_RELAY
        ,HDLApConfig.TYPE_LIGHT_MIX_DIMMER
        ,HDLApConfig.TYPE_LIGHT_MIX_RELAY:
            
            lightBtn.frame = CGRect(x:0, y:statusBarHeight + 60, width:200, height:80)
            lightBtn.setTitle("控制灯光", for:.normal)
            lightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            self.view.addSubview(lightBtn)
            lightBtn.addTarget(self, action:#selector(lightCtrl), for:.touchUpInside)
            
            lightStateLabel.frame =  CGRect(x:50, y:statusBarHeight + 60 + 80, width:200, height:80)
            lightStateLabel.text = "当前状态"
            self.view.addSubview(lightStateLabel)
            
        case HDLApConfig.TYPE_CURTAIN_GLYSTRO
        ,HDLApConfig.TYPE_CURTAIN_ROLLER
        ,HDLApConfig.TYPE_CURTAIN_MODULE:
            
            curtainPauseBtn.frame = CGRect(x:0, y:statusBarHeight + 60, width:120, height:80)
            curtainPauseBtn.setTitle("窗帘暂停", for:.normal)
            curtainPauseBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            self.view.addSubview(curtainPauseBtn)
            curtainPauseBtn.addTarget(self, action:#selector(curtainPauseCtrl), for:.touchUpInside)
            
            curtainOpenBtn.frame = CGRect(x:0, y:statusBarHeight + 60 + 80, width:120, height:80)
            curtainOpenBtn.setTitle("窗帘打开", for:.normal)
            curtainOpenBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            self.view.addSubview(curtainOpenBtn)
            curtainOpenBtn.addTarget(self, action:#selector(curtainOpenCtrl), for:.touchUpInside)
            
            curtainCloseBtn.frame = CGRect(x:0, y:statusBarHeight + 60 + 80 + 80, width:120, height:80)
            curtainCloseBtn.setTitle("窗帘关闭", for:.normal)
            curtainCloseBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            self.view.addSubview(curtainCloseBtn)
            curtainCloseBtn.addTarget(self, action:#selector(curtainCloseCtrl), for:.touchUpInside)
            
            curtainStateLabel.frame =  CGRect(x:0, y:statusBarHeight + 60 + 80 + 80 + 80 + 80, width:200, height:80)
            curtainStateLabel.text = "当前状态"
            self.view.addSubview(curtainStateLabel)
            
            if((info!.deviceType!) != HDLApConfig.TYPE_CURTAIN_MODULE){//如果不是窗帘模块，则卷帘、开合帘拥有百分比控制方法
                curtainPercentBtn.frame = CGRect(x:0, y:statusBarHeight + 60 + 80 + 80 + 80, width:200, height:80)
                curtainPercentBtn.setTitle("窗帘百分比控制", for:.normal)
                curtainPercentBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                self.view.addSubview(curtainPercentBtn)
                curtainPercentBtn.addTarget(self, action:#selector(curtainPercentCtrl), for:.touchUpInside)
            }
            
            
        case HDLApConfig.TYPE_AC_HVAC
        ,HDLApConfig.TYPE_AC_PANEL:
            sceneCtrlBtn.frame = CGRect(x:0, y:statusBarHeight + 60, width:120, height:80)
            sceneCtrlBtn.setTitle("空调控制", for:.normal)
            sceneCtrlBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            self.view.addSubview(sceneCtrlBtn)
            sceneCtrlBtn.addTarget(self, action:#selector(airCtrl), for:.touchUpInside)
            
            airStateLabel.frame =  CGRect(x:0, y:statusBarHeight + 60 + 80 , width:200, height:80)
            airStateLabel.text = "当前状态"
            self.view.addSubview(airStateLabel)
        case HDLApConfig.TYPE_LOGIC_MODULE
        ,HDLApConfig.TYPE_GLOBAL_LOGIC_MODULE:
            sceneCtrlBtn.frame = CGRect(x:0, y:statusBarHeight + 60, width:120, height:80)
            sceneCtrlBtn.setTitle(info!.remarks, for:.normal)
            sceneCtrlBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            self.view.addSubview(sceneCtrlBtn)
            sceneCtrlBtn.addTarget(self, action:#selector(sceneCtrl), for:.touchUpInside)
            
            sceneStateLabel.frame =  CGRect(x:0, y:statusBarHeight + 60 + 80 , width:300, height:80)
            sceneStateLabel.text = "当前状态"
            self.view.addSubview(sceneStateLabel)
        default:
            print("未知设备类型")
        }
        
    }
    
    private func registerForHDL(){
        //        Demo为了演示直接拿此参数，在一个界面注册一种设备Delegate。若在同一界面需要控制多种设备则可以如下连续注册
        //        HDLCommand.shareInstance.registerDelegate(type: HDLApConfig.TYPE_LIGHT, delegate: self)
        //        HDLCommand.shareInstance.registerDelegate(type: HDLApConfig.TYPE_CURTAIN, delegate: self)
        //        HDLCommand.shareInstance.registerDelegate(type: HDLApConfig.TYPE_AC, delegate: self)
        //        HDLCommand.shareInstance.registerDelegate(type: HDLApConfig.TYPE_LOGIC, delegate: self)
        
        HDLCommand.shareInstance.registerDelegate(delegate: self, type: self.info!.bigType!)
        
    }
    
    private func getStateForHDL(){
        //        获取某个设备回路的状态。若要获取所有回路状态则需要自行遍历。注意：场景无状态接口，若为场景调用此方法，无任何作用
        HDLCommand.shareInstance.getDeviceState(delegate: self, appliancesInfo: self.info!)
    }
    
    
    @objc func lightCtrl(){
        HDLCommand.shareInstance.lightCtrl(delegate: self, appliancesInfo: self.info!, state: lightState)
    }
    
    @objc func curtainPauseCtrl(){
        HDLCommand.shareInstance.curtainCtrl(delegate: self, appliancesInfo: self.info!, state: CurtainCtrlParser.shareInstance.curtainPause)
    }
    
    @objc func curtainOpenCtrl(){
        HDLCommand.shareInstance.curtainCtrl(delegate: self, appliancesInfo: self.info!, state: CurtainCtrlParser.shareInstance.curtainOpen)
    }
    
    @objc func curtainCloseCtrl(){
        HDLCommand.shareInstance.curtainCtrl(delegate: self, appliancesInfo: self.info!, state: CurtainCtrlParser.shareInstance.curtainClose)
    }
    
    @objc func curtainPercentCtrl(){
        //state范围：0 - 100
        HDLCommand.shareInstance.curtainCtrl(delegate: self, appliancesInfo: self.info!, state: 50)
        
    }
    
    @objc func airCtrl(){
        
        
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
    }
    
    @objc func sceneCtrl(){
        HDLCommand.shareInstance.sceneCtrl(appliancesInfo: self.info!)
    }
    
    /// 灯光控制反馈信息
    ///
    /// - Parameter lightCtrlBackInfo: 灯光控制反馈Bean
    func getLightCtrlInfo(lightCtrlBackInfo: LightCtrlBackInfo) {
        if(!lightCtrlBackInfo.isSuccessCtrl){
            lightStateLabel.text = "控制超时，请重新控制"
            return
        }
        if(lightCtrlBackInfo.appliancesInfo!.deviceSubnetID == info!.deviceSubnetID
            && lightCtrlBackInfo.appliancesInfo!.deviceDeviceID == info!.deviceDeviceID
            && lightCtrlBackInfo.appliancesInfo!.channelNum == info!.channelNum){
            lightState = lightCtrlBackInfo.brightness!
            lightStateLabel.text = "当前亮度:\(lightState)"
            //将亮度重置为0或100，仅作为测试演示。连续点击可实现开灯、关灯
            if(lightState == 100){
                lightState = 0
            }else{
                lightState = 100
            }
            
            
        }
    }
    
    
    /// 窗帘控制反馈信息
    ///
    /// - Parameter curtainCtrlBackInfo: 窗帘控制反馈Bean
    func getCurtainCtrlInfo(curtainCtrlBackInfo: CurtainCtrlBackInfo) {
        if(!curtainCtrlBackInfo.isSuccessCtrl){
            curtainStateLabel.text = "窗帘控制超时，请重新控制"
            return
        }
        if(curtainCtrlBackInfo.appliancesInfo!.deviceSubnetID == info!.deviceSubnetID
            && curtainCtrlBackInfo.appliancesInfo!.deviceDeviceID == info!.deviceDeviceID
            && curtainCtrlBackInfo.appliancesInfo!.channelNum == info!.channelNum){
            let curState:Int = curtainCtrlBackInfo.state!
            if(curtainCtrlBackInfo.appliancesInfo!.deviceType == HDLApConfig.TYPE_CURTAIN_MODULE){
                //判断为窗帘模块，只返回以下3个状态
                switch curState {
                case CurtainCtrlParser.TYPE_STATE_CLOSE:
                    curtainStateLabel.text = "窗帘关"
                case CurtainCtrlParser.TYPE_STATE_OPEN:
                    curtainStateLabel.text = "窗帘开"
                case CurtainCtrlParser.TYPE_STATE_PAUSE:
                    curtainStateLabel.text = "窗帘停"
                default:
                    print("未知")
                }
            }else{
                //判断为卷帘或开合帘，只返回百分比
                curtainStateLabel.text = "当前窗帘开合度：\(curState)"
                print("当前窗帘开合度：\(curState)")
            }
        }
    }
    
    
    /// 空调控制反馈
    ///
    /// - Parameter airCtrlBackInfo: 空调控制反馈Bean
    func getAirCtrlInfo(airCtrlBackInfo: AirCtrlBackInfo) {
        if(!airCtrlBackInfo.isSuccessCtrl){
            airStateLabel.text = "空调控制超时，请重新控制"
            return
        }
        if(airCtrlBackInfo.appliancesInfo!.deviceSubnetID == info!.deviceSubnetID
            && airCtrlBackInfo.appliancesInfo!.deviceDeviceID == info!.deviceDeviceID
            && airCtrlBackInfo.appliancesInfo!.channelNum == info!.channelNum){
            
            var curState:[Int] = airCtrlBackInfo.arrCurState!
            
            switch curState[0] {
            case AirCtrlParser.shareInstance.airSwich:
                switch curState[1] {
                case AirCtrlParser.shareInstance.airOff:
                    airStateLabel.text = "空调关"
                case AirCtrlParser.shareInstance.airOn:
                    airStateLabel.text = "空调开"
                default:
                    break
                }
            case AirCtrlParser.shareInstance.refTem:
                airStateLabel.text = "空调制冷，温度为：\(curState[1])"
            case AirCtrlParser.shareInstance.airSpeed :
                switch curState[1] {
                case AirCtrlParser.shareInstance.airSpeedAuto:
                    airStateLabel.text = "空调风速，风速模式为：自动风速"
                case AirCtrlParser.shareInstance.airSpeedHigh:
                    airStateLabel.text = "空调风速，风速模式为：风速高"
                case AirCtrlParser.shareInstance.airSpeedMid:
                    airStateLabel.text = "空调风速，风速模式为：风速中"
                case AirCtrlParser.shareInstance.airSpeedLow:
                    airStateLabel.text = "空调风速，风速模式为：风速低"
                default:
                    break;
                }
            case AirCtrlParser.shareInstance.airMode:
                switch curState[1] {
                case AirCtrlParser.shareInstance.airModeRefTem:
                    airStateLabel.text = "空调模式，模式为：制冷"
                case AirCtrlParser.shareInstance.airModeHeatTem:
                    airStateLabel.text = "空调模式，模式为：制热"
                case AirCtrlParser.shareInstance.airModeVen:
                    airStateLabel.text = "空调模式，模式为：通风"
                case AirCtrlParser.shareInstance.airModeAuto:
                    airStateLabel.text = "空调模式，模式为：自动"
                case AirCtrlParser.shareInstance.airModeDehum:
                    airStateLabel.text = "空调模式，模式为：抽湿"
                default:
                    break
                }
            case AirCtrlParser.shareInstance.heatTem:
                airStateLabel.text = "空调制热，制热温度为:\(curState[1])"
            case AirCtrlParser.shareInstance.autoTem:
                airStateLabel.text = "空调自动，自动温度为:\(curState[1])"
            case AirCtrlParser.shareInstance.dehumTem:
                airStateLabel.text = "空调抽湿，抽湿温度为:\(curState[1])"
            case AirCtrlParser.shareInstance.upTem:
                airStateLabel.text = "空调调温，上升温度:\(curState[1])"
            case AirCtrlParser.shareInstance.downTem:
                airStateLabel.text = "空调调温，下降温度:\(curState[1])"
            default:
                print("未知类型")
            }
            
        }
    }
    
    
    
    /// 主动获取设备状态反馈信息
    ///
    /// - Parameter devicesStateBackInfo: 获取设备状态Bean
    func getDevicesState(devicesStateBackInfo: DevicesStateBackInfo) {
        if(!devicesStateBackInfo.isSuccess){
            print("获取设备状态超时，请重新再试")
            return
        }
        let appliancesInfo = devicesStateBackInfo.appliancesInfo!
        if(appliancesInfo.deviceSubnetID == self.info!.deviceSubnetID
            && appliancesInfo.deviceDeviceID == self.info!.deviceDeviceID
            ){
            switch (appliancesInfo.deviceType!) {
            case HDLApConfig.TYPE_LIGHT_DIMMER
            ,HDLApConfig.TYPE_LIGHT_RELAY
            ,HDLApConfig.TYPE_LIGHT_MIX_DIMMER
            ,HDLApConfig.TYPE_LIGHT_MIX_RELAY:
                if(appliancesInfo.channelNum == self.info!.channelNum){
                    let curState:Int = appliancesInfo.curState! as! Int
                    lightStateLabel.text = "当前亮度:\(curState)"
                    if(curState == 100){
                        lightState = 0
                    }else{
                        lightState = 100
                    }
                }
            case HDLApConfig.TYPE_CURTAIN_GLYSTRO
            ,HDLApConfig.TYPE_CURTAIN_ROLLER
            ,HDLApConfig.TYPE_CURTAIN_MODULE:
                let curState:Int = appliancesInfo.curState! as! Int
                if((appliancesInfo.deviceType!) == HDLApConfig.TYPE_CURTAIN_MODULE){//判断是否为窗帘模块,否则为开合帘或卷帘电机
                    switch (curState){
                    case CurtainCtrlParser.shareInstance.curtainClose:
                        curtainStateLabel.text = "窗帘关"
                    case CurtainCtrlParser.shareInstance.curtainOpen:
                        curtainStateLabel.text = "窗帘开"
                    case CurtainCtrlParser.shareInstance.curtainPause:
                        curtainStateLabel.text = "窗帘暂停"
                    default:
                        curtainStateLabel.text = "未知状态"
                    }
                }else{
                    curtainStateLabel.text = "当前百分比：\(curState)"
                }
            case HDLApConfig.TYPE_AC_HVAC,HDLApConfig.TYPE_AC_PANEL:
                if(appliancesInfo.channelNum == self.info!.channelNum){
                    let curState:[Int] = appliancesInfo.arrCurState!
                    
                    switch curState[0] {
                    case AirCtrlParser.shareInstance.airSwich:
                        switch curState[1] {
                        case AirCtrlParser.shareInstance.airOff:
                            airStateLabel.text = "空调关"
                            print("空调关")
                        case AirCtrlParser.shareInstance.airOn:
                            airStateLabel.text = "空调开"
                            print("空调开")
                        default:
                            break
                        }
                    case AirCtrlParser.shareInstance.refTem:
                        airStateLabel.text = "空调制冷，温度为：\(curState[1])"
                        print("空调制冷，温度为：\(curState[1])")
                    case AirCtrlParser.shareInstance.airSpeed :
                        switch curState[1] {
                        case AirCtrlParser.shareInstance.airSpeedAuto:
                            airStateLabel.text = "空调风速，风速模式为：自动风速"
                            print("空调风速，风速模式为：自动风速")
                        case AirCtrlParser.shareInstance.airSpeedHigh:
                            airStateLabel.text = "空调风速，风速模式为：风速高"
                            print("空调风速，风速模式为：风速高")
                        case AirCtrlParser.shareInstance.airSpeedMid:
                            airStateLabel.text = "空调风速，风速模式为：风速中"
                            print("空调风速，风速模式为：风速中")
                        case AirCtrlParser.shareInstance.airSpeedLow:
                            airStateLabel.text = "空调风速，风速模式为：风速低"
                            print("空调风速，风速模式为：风速低")
                        default:
                            break;
                        }
                    case AirCtrlParser.shareInstance.airMode:
                        switch curState[1] {
                        case AirCtrlParser.shareInstance.airModeRefTem:
                            airStateLabel.text = "空调模式，模式为：制冷"
                            print("空调模式，模式为：制冷")
                        case AirCtrlParser.shareInstance.airModeHeatTem:
                            airStateLabel.text = "空调模式，模式为：制热"
                            print("空调模式，模式为：制热")
                        case AirCtrlParser.shareInstance.airModeVen:
                            airStateLabel.text = "空调模式，模式为：通风"
                            print("空调模式，模式为：通风")
                        case AirCtrlParser.shareInstance.airModeAuto:
                            airStateLabel.text = "空调模式，模式为：自动"
                            print("空调模式，模式为：自动")
                        case AirCtrlParser.shareInstance.airModeDehum:
                            airStateLabel.text = "空调模式，模式为：抽湿"
                            print("空调模式，模式为：抽湿")
                        default:
                            break
                        }
                    case AirCtrlParser.shareInstance.heatTem:
                        airStateLabel.text = "空调制热，制热温度为:\(curState[1])"
                        print("空调制热，制热温度为:\(curState[1])")
                    case AirCtrlParser.shareInstance.autoTem:
                        airStateLabel.text = "空调自动，自动温度为:\(curState[1])"
                        print("空调自动，自动温度为:\(curState[1])")
                    case AirCtrlParser.shareInstance.dehumTem:
                        airStateLabel.text = "空调抽湿，抽湿温度为:\(curState[1])"
                        print("空调抽湿，抽湿温度为:\(curState[1])")
                    case AirCtrlParser.shareInstance.upTem:
                        airStateLabel.text = "空调调温，上升温度:\(curState[1])"
                        print("空调调温，上升温度:\(curState[1])")
                    case AirCtrlParser.shareInstance.downTem:
                        airStateLabel.text = "空调调温，下降温度:\(curState[1])"
                        print("空调调温，下降温度:\(curState[1])")
                    default:
                        print("未知类型")
                        print("未知类型")
                    }
                    
                }
            default:
                print("未知设备类型")
                print("未知设备类型")
            }
        }
    }
    
    func getSceneCtrlInfo(sceneCtrlBackInfo: SceneCtrlBackInfo) {
        if(!sceneCtrlBackInfo.isSuccessCtrl){
            sceneStateLabel.text = "场景控制超时，请重新控制"
            return
        }
        if(sceneCtrlBackInfo.appliancesInfo?.deviceSubnetID == info!.deviceSubnetID
            && sceneCtrlBackInfo.appliancesInfo?.deviceDeviceID == info!.deviceDeviceID
            && sceneCtrlBackInfo.areaNum == info!.logicMode!.areaNum
            && sceneCtrlBackInfo.areaSceneNum == info!.logicMode!.areaSceneNum){
            sceneStateLabel.text = "\(info!.remarks) 场景控制成功"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
