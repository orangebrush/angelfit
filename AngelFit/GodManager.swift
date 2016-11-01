//
//  AngelBleModule.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/10/31.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import UIKit
import CoreBluetooth

//MARK:- delegate
public protocol GodManagerDelegate {
    func godManager(didDiscoverPeripheral peripheral: CBPeripheral, withRSSI RSSI: NSNumber, peripheralName name: String)
}

public class GodManager: NSObject {
    
    fileprivate var delegate: GodManagerDelegate?       //代理
    
    
    
    //Mark:- 扫描设备----------------------
    public func scanDevice(){

        let queue = DispatchQueue.global(qos: .default)
        let manager = CBCentralManager(delegate: self, queue: queue)
        manager.scanForPeripherals(withServices: [MainUUID.service], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])

    }
}

extension GodManager: CBCentralManagerDelegate{
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        delegate?.godManager(didDiscoverPeripheral: peripheral, withRSSI: RSSI, peripheralName: advertisementData["kCBAdvDataLocalName"] as! String)
    }
}
