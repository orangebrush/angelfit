//
//  ViewController.swift
//  AngelFitSample
//
//  Created by ganyi on 2016/11/1.
//  Copyright © 2016年 ganyi. All rights reserved.
//

import UIKit
import AngelFit
import CoreBluetooth
class ViewController: UIViewController {
    @IBOutlet weak var myTableView: UITableView!
    fileprivate var peripheralTuple = [(name: String, RSSI: NSNumber, peripheral: CBPeripheral)]()
    
    fileprivate let godManager = GodManager.share()
    
    fileprivate let handler = CoreDataHandler()

    override func viewDidLoad() {
        super.viewDidLoad()
       
        config()
        createContents()
    }

    private func config(){
        
        godManager.delegate = self
    }
    
    private func createContents(){
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func scanDevice(_ sender: Any) {
        peripheralTuple.removeAll()
         godManager.startScan()
//        let device = handler.insertDevice(withMacAddress: "textMacAddress", withItems: ["battLevel": 4])
//        device?.bandStatus = 222
//        
//        
//        if let device2 = handler.selectDevice(userId: 1, withMacAddress: "textMacAddress"){
//            print("ddddddddddd")
//            print(device2)
//            device2.bandStatus = 333
//            print("bbbbbbbbbbb")
//            
//            if let device3 = handler.selectDevice(userId: 1, withMacAddress: "textMacAddress") {
//                print("cccccccccc")
//                print(device3)
//                print("oooooooooooo")
//            }
//        }
    }
    
    @IBAction func bandDevice(_ sender: Any) {
        let interfaceManager = InterfaceListManager()
        interfaceManager.setMusicSwitch(withParam: true, closure: { status in
            print("设置状态 : \(status)")
        })
        
//        let interfaceManager = InterfaceListManager()
//        interfaceManager.setSynchronization(closure: { status , percent in
//            print("同步状态: \(status)  同步百分比: \(percent)")
//        })
        
//        interfaceManager.setCamera(withParam: true, closure:{
//            type in
//            print("正在拍照: \(type)")
//        })
        
//        interfaceManager.manage(type: ActionType.macAddress, param: nil, closure: {
//            complete, result in
//            
//            
//            guard complete else{
//                return
//            }
//            
//            guard let res = result else{
//                return
//            }
//            
//            
//        })
        
        
        return
        guard let curPeripharel = PeripheralManager.share().currentPeripheral else{
            print("currentPeripharel is not exist!")
            return
        }
        
        print("currentPeripharel is \(curPeripharel.name)")
        
        
        handler.deleteDevice(withMacAddress: "textMacAddress")
        
        let device = handler.selectDevice(userId: 1, withMacAddress: "textMacAddress")
        print("uuuuuuuuuuu")
        print(device ?? "not nil")
        print("nnnnnnnnnnn")
    }
}

//MARK:- GodManager 代理实现
extension ViewController: GodManagerDelegate{
    func godManager(didDiscoverPeripheral peripheral: CBPeripheral, withRSSI RSSI: NSNumber, peripheralName name: String){
        print(name)
        print(peripheral)
        print(RSSI)
        let res = Thread.isMainThread ? "main" : "global"
        print(res)
        peripheralTuple.append((name, RSSI, peripheral))
        myTableView.reloadData()
    }
    func godManager(didUpdateCentralState state: GodManagerState) {
        print("连接状态: \(state)")
    }
    func godManager(didUpdateConnectState state: GodManagerConnectState, withPeripheral peripheral: CBPeripheral, withError error: Error?) {
        print(state)
        if state == .connect{
        
        }
    }
    
    func godManager(didConnectedPeripheral peripheral: CBPeripheral, connectState isSuccess: Bool) {
        print("connect \(peripheral.name)--\(isSuccess ? "成功" : "失败")")
    }
    
    func godManager(bindingPeripheralsUUID UUIDList: [String]) {
        print("已绑定的设备列表: \(UUIDList)")
    }
}
extension ViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralTuple.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = peripheralTuple[indexPath.row]
        godManager.connect(element.peripheral)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identy = "cell"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identy)
        if cell == nil{
            cell = UITableViewCell(style: .value1, reuseIdentifier: identy)
        }
        let element = peripheralTuple[indexPath.row]
        cell?.textLabel?.text = element.name
        cell?.detailTextLabel?.text = "\(element.RSSI)"
        return cell!
    }
}
