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
    
    fileprivate let handler = CoreDataHandler.share()

    override func viewDidLoad() {
        super.viewDidLoad()
       
        config()
        createContents()
    }

    private func config(){
        
        godManager.delegate = self
    }
    
    private func createContents(){
        let networkHandler = NetworkHandler.share()
        let param: [String: Any] = ["userId": "ganyi",
                                    "password": "123456",
                                    "email": "123456@qq.com"]
        
        networkHandler.user.add(withParam: param, closure: {
            resultCode, message, data in
            print(resultCode)
            print(message)
            print(data)
            
            networkHandler.user.logon(withUserId: "ganyi", withPassword: "123456", closure: {
                resultCode, message, data in
                print(resultCode)
                print(message)
                print(data)
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func scanDevice(_ sender: Any) {
        peripheralTuple.removeAll()
         godManager.startScan()
    }
    
    var secClick = false
    //MARK:- text
    @IBAction func bandDevice(_ sender: Any) {
        
        
        
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
