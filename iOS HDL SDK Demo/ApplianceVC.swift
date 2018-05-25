//
//  ApplianceVC.swift
//  HDLSDKDemo3
//
//  Created by Tommy on 2018/4/20.
//  Copyright © 2018年 Tommy. All rights reserved.
//

import UIKit
import HDLSDK

class ApplianceVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var tableView:UITableView?
    var appliancesInfo:[AppliancesInfo]?
    var remark:[String] = []
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let statusBarWidth = UIApplication.shared.statusBarFrame.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        for value in appliancesInfo! {
            var state = ""
            if(value.remarks.isEmpty){
                state += "暂无备注"
            }else{
                state += value.remarks
            }
            switch value.deviceType {
            case HDLApConfig.TYPE_LIGHT_DIMMER
            ,HDLApConfig.TYPE_LIGHT_RELAY
            ,HDLApConfig.TYPE_LIGHT_MIX_DIMMER
            ,HDLApConfig.TYPE_LIGHT_MIX_RELAY:
                state += "   当前灯光回路亮度：\(value.curState)"
            case HDLApConfig.TYPE_CURTAIN_GLYSTRO
            ,HDLApConfig.TYPE_CURTAIN_ROLLER:
                state += "  当前窗帘回路开合百分比：\(value.curState) %"
            case HDLApConfig.TYPE_CURTAIN_MODULE:
                switch value.curState {
                case 0:
                    state += "  窗帘模块停止状态"
                case 1:
                    state += "  窗帘模块开状态"
                case 2:
                    state += "  窗帘模块关状态"
                default:
                    break
                }
            case HDLApConfig.TYPE_AC_HVAC,HDLApConfig.TYPE_AC_PANEL:
                for index in 0...(value.arrCurState.count - 1) {
                    if(index == 0 && value.arrCurState[index] == 0){
                        state += " 空调已关闭"
                        //如果空调关闭状态，则无需再遍历
                        break
                    }
                    if(index == 0 && value.arrCurState[index] == 1){
                        state += " 空调正在运行"
                    }
                    switch index {
                        
                    case 1:
                        switch value.arrCurState[index]{
                        case 0:
                            state += " 空调模式:制冷"
                        case 1:
                            state += " 空调模式:制热"
                        case 2:
                            state += " 空调模式:通风"
                        case 3:
                            state += " 空调模式:自动"
                        case 4:
                            state += " 空调模式:抽湿"
                        default:
                            state += " 未知空调模式"
                        }
                    case 2:
                        switch value.arrCurState[1]{
                        case 0:
                            state += " 制冷温度：\(value.arrCurState[index])"
                        case 1:
                            state += " 制热温度：\(value.arrCurState[index])"
                        case 2:
                            state += " 通风模式下，无温度显示"
                        case 3:
                            state += " 自动温度：\(value.arrCurState[index])"
                        case 4:
                            state += " 抽湿温度：\(value.arrCurState[index])"
                        default:
                            state += " 未知温度"
                        }
                    case 3:
                        var curSpeed = ""
                        switch value.arrCurState[index] {
                        case 0:
                            curSpeed = " 风速自动"
                        case 1:
                            curSpeed = " 风速高"
                        case 2:
                            curSpeed = " 风速中"
                        case 3:
                            curSpeed = " 风速低"
                        default:
                            curSpeed = " 未知风速"
                        }
                        switch value.arrCurState[1]{
                        case 0:
                            state += curSpeed
                        case 1:
                            state += curSpeed
                        case 2:
                            state += curSpeed
                        case 3:
                            state += curSpeed
                        case 4:
                            state += " 抽湿无风速"
                        default:
                            state += " 未知空调模式"
                            break
                        }
                        
                    default:
                        break
                    }
                }
            default:
                break
            }
            self.remark.append(state)
            print(state)
        }
        
        
        
        self.tableView = UITableView(frame: CGRect(x:0, y:statusBarHeight, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height), style:.plain)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.register(UITableViewCell.self,forCellReuseIdentifier: "SwiftCell")
        self.view.addSubview(self.tableView!)
        
        
//        HDLCommand.shareInstance.listlLightsCtrl(delegate: <#T##Any#>, appliancesInfos: <#T##[AppliancesInfo]#>, states: <#T##[Int]#>)
        
//        HDLCommand.shareInstance.listCurtainCtrl(delegate: <#T##Any#>, appliancesInfo: <#T##[AppliancesInfo]#>, states: <#T##[Int]#>)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.remark.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identify:String = "SwiftCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identify,for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = self.remark[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView!.deselectRow(at: indexPath, animated: true)
        
        let info:AppliancesInfo = self.appliancesInfo![indexPath.row]
        
        self.performSegue(withIdentifier: "ShowCtrlView", sender: info)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCtrlView"{
            let controller = segue.destination as! CtrlVC
            controller.info = sender as? AppliancesInfo
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
