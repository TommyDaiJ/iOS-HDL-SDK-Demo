//
//  ViewController.swift
//  HDLSDKDemo3
//
//  Created by Tommy on 2018/4/8.
//  Copyright © 2018年 Tommy. All rights reserved.
//

import UIKit
import HDLSDK

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource,DevicesInfoDelegate,ScenesInfoDelegate{
    
    var activityIndicator:UIActivityIndicatorView!
    var tableView:UITableView?
    var devicesRemark:[String] = [] //设备备注。（例如：一个继电器灯光设备会有N个回路）
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let statusBarWidth = UIApplication.shared.statusBarFrame.width
    var devicesData:[DevicesData] = []
    let searchLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let searchAL:UIButton = UIButton(type:.system)
        searchAL.frame = CGRect(x:10, y:statusBarHeight + 47, width:180, height:40)
        searchAL.setTitle("搜索HDL设备", for:.normal)
        self.view.addSubview(searchAL)
        searchAL.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        searchAL.addTarget(self, action:#selector(searchHdlAL), for:.touchUpInside)
        
        let searchScene:UIButton = UIButton(type:.system)
        searchScene.frame = CGRect(x:200, y:statusBarHeight + 47, width:180, height:40)
        searchScene.setTitle("搜索HDL场景", for:.normal)
        self.view.addSubview(searchScene)
        searchScene.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        searchScene.addTarget(self, action:#selector(searchHdlScene), for:.touchUpInside)
        
        
        searchLabel.frame =  CGRect(x:0, y:statusBarHeight + 47 + 40, width:350, height:80)
        searchLabel.text = "搜索状态：暂无设备"
        self.view.addSubview(searchLabel)
        
        
        self.tableView = UITableView(frame: CGRect(x:0, y:statusBarHeight + 90 + 80, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height - 190), style:.plain)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.register(UITableViewCell.self,forCellReuseIdentifier: "SwiftCell")
        self.view.addSubview(self.tableView!)
        
        
        
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:
            UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.color = UIColor.black
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator);
        
        HDLManager.shareInstance.initSDK()
        
        
        
    }
    
    
    @objc func searchHdlAL(){
        activityIndicator.startAnimating()
        HDLCommand.shareInstance.devicesSearch(delegate: self)
    }
    
    @objc func searchHdlScene(){
        activityIndicator.startAnimating()
        HDLCommand.shareInstance.scenesSearch(delegate: self)
    }
    
    
    /// 搜索设备的回调函数
    ///
    /// - Parameter devicesData: 设备信息集
    func getDevicesData(searchDevicesBackInfo: SearchDevicesBackInfo) {
        activityIndicator.stopAnimating()
        devicesRemark.removeAll()
        if(!(searchDevicesBackInfo.isSuccess)){
            searchLabel.text = "搜索超时，请重新再试"
            self.tableView?.reloadData()
            return
        }
        handleSearchData(devicesData: searchDevicesBackInfo.devicesData!)
    }
    
    
    /// 搜索场景的回调函数
    ///
    /// - Parameter devicesData: 设备信息集
    func getScenesData(searchDevicesBackInfo: SearchDevicesBackInfo) {
        activityIndicator.stopAnimating()
        devicesRemark.removeAll()
        if(!(searchDevicesBackInfo.isSuccess)){
            searchLabel.text = "搜索超时，请重新再试"
            self.tableView?.reloadData()
            return
        }
        handleSearchData(devicesData: searchDevicesBackInfo.devicesData!)
    }
    
    private func handleSearchData(devicesData: [DevicesData]){
        activityIndicator.stopAnimating()
        searchLabel.text = "搜索成功！请点击相关设备控制！"
        self.devicesData = devicesData
        for value in devicesData {
            var remark:String = ""
            
            if(value.remark.trimmingCharacters(in: .whitespaces).isEmpty
                ){
                remark = "暂无备注"
            }else{
                remark = value.remark
            }
            devicesRemark.append(remark)
            
            print("收到设备信息 子网号：\(value.sourceSubnetID) 设备号：\(value.sourceDeviceID) 备注：\(remark)")
            
        }
        self.tableView?.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devicesRemark.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        let identify:String = "SwiftCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identify,for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = self.devicesRemark[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView!.deselectRow(at: indexPath, animated: true)
        
        let appliancesInfo:[AppliancesInfo] = self.devicesData[indexPath.row].appliancesInfoList
        
        self.performSegue(withIdentifier: "ShowApplianceView", sender: appliancesInfo)
    }
    
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowApplianceView"{
            let controller = segue.destination as! ApplianceVC
            controller.appliancesInfo = sender as? [AppliancesInfo]
        }
    }
    
    //滑动删除必须实现的方法
    func tableView(_ tableView: UITableView,commit editingStyle: UITableViewCellEditingStyle,forRowAt indexPath: IndexPath) {
        print("删除\(indexPath.row)")
        let index = indexPath.row
        self.devicesRemark.remove(at: index)
        self.tableView?.deleteRows(at: [indexPath],with: .top)
    }
    
    //滑动删除
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCellEditingStyle {
            return UITableViewCellEditingStyle.delete
    }
    
    //修改删除按钮的文字
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt
        indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

