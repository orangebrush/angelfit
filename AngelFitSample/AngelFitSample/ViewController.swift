//
//  ViewController.swift
//  AngelFitSample
//
//  Created by ganyi on 2016/11/1.
//  Copyright © 2016年 ganyi. All rights reserved.
//

import UIKit
import AngelFit
//import AngelFitNetwork
import CoreBluetooth
class ViewController: UIViewController {
    @IBOutlet weak var myTableView: UITableView!
    fileprivate var peripheralTuple = [(name: String, RSSI: NSNumber, peripheral: CBPeripheral)]()
    
    fileprivate let godManager = GodManager.share()
    
    fileprivate let handler = CoreDataHandler.share()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        config()
        //createContents()
    }

    private func config(){
        
        godManager.delegate = self
    }
    
    private func createContents(){
        
        let networkHandler = NetworkHandler.share()
        let macaddress = "ASD4ID8EK2"
        let deviceId = "1" + macaddress + "123"
        let userId = "283925583@qq.com"
        
        
        //添加设备
        let deviceParam = NWHDeviceParam()
        deviceParam.id = deviceId
        deviceParam.macAddress = macaddress
        deviceParam.name = "id107-hr"
        deviceParam.showName = "ganyi's band"
        deviceParam.totalUserdMinutes = 1
        deviceParam.type = kNWHDeviceTypeBand
        deviceParam.batteryType = kNWHDeviceBatteryTypeLithiumCell
        networkHandler.device.add(withParam: deviceParam, closure: {
            resultCode, message, data in
            print("<添加设备>resultCode: \(resultCode), message: " + message + ", data: \(String(describing: data))")
            
            //记录设备状态
            let deviceStatusParam = NWHDeviceStatusParam()
            deviceStatusParam.deviceId = deviceId
            deviceStatusParam.batteryStatus = kNWHDeviceBatteryStatusNormal
            deviceStatusParam.batteryVoltage = 50
            deviceStatusParam.batteryLevel = 80
            deviceStatusParam.totalUsedMinutes = 1
            networkHandler.device.recordState(withParam: deviceStatusParam, closure: {
                resultCode, message, data in
                print("<记录设备状态>resultCode: \(resultCode), message: " + message + ", data: \(String(describing: data))")
            })
            
            //更新功能列表
            let deviceFunctable = NWHDeviceFunctableParam()
            deviceFunctable.deviceId = deviceId
            deviceFunctable.haveScreenDisplay180Rotate = true
            networkHandler.device.recordFunctable(withParam: deviceFunctable, closure: {
                resultCode, message, data in
                print("<添加设备功能列表>resultCode: \(resultCode), message: " + message + ", data: \(String(describing: data))")
                
                //获取设备功能列表
                //let deviceFunctable2 = NWHDeviceFunctableParam()
                
            })
        })
        
        let stepAddParam = NWHStepAddParam()
        /*
        //上传心率
        let heartrateParam = NWHHeartrateAddParam()
        heartrateParam.deviceId = deviceId
        heartrateParam.userId = userId
        heartrateParam.date = Date()
        heartrateParam.silentHeartRate = 70
        heartrateParam.burnFatThreshold = 123
        heartrateParam.aerobicThreshold = 1234
        heartrateParam.limitThreshold = 32
        heartrateParam.burnFatMinutes = 234
        heartrateParam.aerobicMinutes = 123
        heartrateParam.limitMinutes = 1
        heartrateParam.itemsStartTime = Date()
        heartrateParam.items = [(5, 63), (6, 89), (5, 34), (5, 120)]
        networkHandler.everyday.addEverydayHeartrates(withParam: [heartrateParam], closure: {
            resultCode, message, data in
            print("<add everyday>param: \(heartrateParam)\nresultCode: \(resultCode)\nmessage: \(message)\ndata: \(String(describing: data))")
            print(data)
            
            let pullParam = NWHEverydayDataPullParam()
            pullParam.userId = userId
            pullParam.deviceId = nil
            networkHandler.everyday.pullEverydayHeartrates(withParam: pullParam, closure: {
                resultCode, message, data in
                print("<pull everyday>param: \(pullParam)\nresultCode: \(resultCode)\nmessage: \(message)\ndata: \(String(describing: data))")
                print(data)
            })
            
            //获取最后同步时间
            let lastParam = NWHLastSyncDateParam()
            lastParam.userId = userId
            lastParam.deviceId = deviceId
            networkHandler.everyday.getLastSyncDate(withParam: lastParam, closure: {
                resultCode, message, data in
                print("<last sync>param: \(pullParam)\nresultCode: \(resultCode)\nmessage: \(message)\ndata: \(String(describing: data))")
                if let d = data as? [String: Any?]{
                    if let heartrateDate = d["heartRateDate"] {
                        if let hr = heartrateDate {
                            print(hr)
                        }
                    }
                }
            })
        })
        */
 
        /*
        //修改密码
        let changePassword = NWHUserChangePasswordParam()
        changePassword.userId = "283925583@qq.com"
        changePassword.newPassword = "123123"
        networkHandler.user.changePassword(withParam: changePassword, closure: {
            resultCode, message, data in
            
            print(resultCode)
            print(message)
            print(data)
        })
         */
        
        //上传图片
//        let userUploadParam = NWHUserUploadParam()
//        userUploadParam.userId = userId
//        userUploadParam.image = UIImage(named: "headshot")
//        networkHandler.user.uploadPhoto(withParam: userUploadParam, closure: {
//            resultCode, message, data in
//            print("<upload> resultCode: \(resultCode)\nmessage: \(message)\ndata: \(data)")
//        })
        
//        var param: [String: Any] =
//            [
//                "id": "1AESDFE2E8W9W101",
//                "macAddress": "sefe4r5r2eko",
//                "uuid": "12345612",
//                "name": "id111",
//                "showName": "ganyi's band",
//                "type": "1",
//                "batteryType": "\(NWHDeviceBatteryType.lithiumCell.rawValue)",
//                "totalUsedMinutes": 123
//        ]
//
//        //添加设备
//        networkHandler.device.add(withParam: param, closure: {
//            resultCode, message, data in
//            print(resultCode)
//            print(message)
//            print(data)
//            
//            //更新设备
//            param = [
//                "id": "1AESDFE2E8W9W101",
//                "macAddress": "sefe4r5r2eko",
//                "uuid": "12345612",
//                "name": "id1112",
//                "showName": "ganyi's band2",
//                "type": "1",
//                "batteryType": "\(NWHDeviceBatteryType.lithiumCell.rawValue)",
//                "totalUsedMinutes": 1234]
//            networkHandler.device.update(withParam: param, closure: {
//                resultCode, message, data in
//                print(resultCode)
//                print(message)
//                print(data)
//            })
//        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func scanDevice(_ sender: Any) {
        peripheralTuple.removeAll()
         //godManager.startScan()
    }
    
    var secClick = false
    //MARK:- text
    @IBAction func bandDevice(_ sender: Any) {
        
        createContents()
    }
}

//MARK:- GodManager 代理实现
extension ViewController: GodManagerDelegate{
    //获取已连接设备
    func godManager(currentConnectPeripheral peripheral: CBPeripheral, peripheralName name: String) {
        peripheralTuple.append((name, 0, peripheral))
        peripheralTuple = peripheralTuple.sorted{fabs($0.RSSI.floatValue) < fabs($1.RSSI.floatValue)}
        myTableView.reloadData()
    }
    
    func godManager(didDiscoverPeripheral peripheral: CBPeripheral, withRSSI RSSI: NSNumber, peripheralName name: String){

        peripheralTuple.append((name, RSSI, peripheral))
        peripheralTuple = peripheralTuple.sorted{fabs($0.RSSI.floatValue) < fabs($1.RSSI.floatValue)}
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
        cell?.detailTextLabel?.text = element.RSSI == 0 ? "已连接" : "\(element.RSSI)"
        return cell!
    }
}
