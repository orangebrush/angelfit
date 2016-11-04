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
    
    fileprivate let godManager = GodManager()
    
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
//         godManager.startScan()
        let device = handler.insertDevice(withMacAddress: "textMacAddress", withItems: ["battLevel": 4])
        device?.bandStatus = 222
        
        
        if let device2 = handler.selectDevice(userId: 1, withMacAddress: "textMacAddress"){
            print("ddddddddddd")
            print(device2)
            device2.bandStatus = 333
            print("bbbbbbbbbbb")
            
            if let device3 = handler.selectDevice(userId: 1, withMacAddress: "textMacAddress") {
                print("cccccccccc")
                print(device3)
                print("oooooooooooo")
            }
        }
    }
    
    @IBAction func bandDevice(_ sender: Any) {
        
        handler.deleteDevice(withMacAddress: "textMacAddress")
        
        let device = handler.selectDevice(userId: 1, withMacAddress: "textMacAddress")
        print("uuuuuuuuuuu")
        print(device)
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
        print(state)
    }
    func godManager(didUpdateConnectState state: GodManagerConnectState, withPeripheral peripheral: CBPeripheral, withError error: Error?) {
        print(state)
        if state == .connect{
        
        }
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
