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

public final class GodManager: NSObject {
    
    private var centralManager: CBCentralManager?   //蓝牙管理中心
    private var service: CBService{
        return CBMutableService(type: MainUUID.service, primary: true)
    }                                               //蓝牙服务
    open var delegate: GodManagerDelegate?          //GodMangager代理
    
    
    //MARK:- ---------------------------------
    override public init() {
        super.init()
        
        config()
    }
    
    private func config(){
        
        let queue = DispatchQueue.global(priority: .high)
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }

    //Mark:- 开始扫描
    public func startScan(){
        
        centralManager?.scanForPeripherals(withServices: [service.uuid], options: nil)

        //3秒后停止扫描
        delay(3){
            self.stopScan()
        }
    }
    
    //MARK:- 结束扫描
    public func stopScan(){
        
        centralManager?.stopScan()
    }
}

extension GodManager: CBCentralManagerDelegate{
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        delegate?.godManager(didDiscoverPeripheral: peripheral, withRSSI: RSSI, peripheralName: advertisementData["kCBAdvDataLocalName"] as! String)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        case .unknown:
            print("godManager-unknown")
        case .resetting:
            print("godManager-resetting")
        case .unsupported:
            print("godManager-unsupported")
        case .unauthorized:
            print("godManager-unauthorized")
        case .poweredOff:
            print("godManager-poweredOff")
        case .poweredOn:
            print("godManager-poweredOn")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
     
    }
}
