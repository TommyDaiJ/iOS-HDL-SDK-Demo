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
            if(value.remarks.isEmpty){
                self.remark.append("暂无备注")
            }else{
                self.remark.append(value.remarks)
            }
        }
        
        self.tableView = UITableView(frame: CGRect(x:0, y:statusBarHeight, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height), style:.plain)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.register(UITableViewCell.self,forCellReuseIdentifier: "SwiftCell")
        self.view.addSubview(self.tableView!)
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
