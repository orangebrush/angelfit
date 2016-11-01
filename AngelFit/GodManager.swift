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
protocol GodManagerDelegate {
    func godManager(didDiscoverPeripheral peripheralTuple: ())
}

class GodManager: NSObject {
    
    fileprivate var delegate: GodManagerDelegate?       //代理
    
    //数据结构
    fileprivate var peripheralTupleList = [(RSSI: NSNumber, peripheral: CBPeripheral)]()
    
    //Mark:- 扫描设备
    public func scanDevice(){

        let queue = DispatchQueue.global(qos: .default)
        let manager = CBCentralManager(delegate: self, queue: queue)
        manager.scanForPeripherals(withServices: [MainUUID.service], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])

    }
}

extension GodManager: CBCentralManagerDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.godManager(didDiscoverPeripheral: peripheral ,RSSI: RSSI)
    }
}
