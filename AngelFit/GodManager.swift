//
//  AngelBleModule.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/10/31.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import UIKit
import CoreBluetooth

//MARK:- 蓝牙中心状态
public enum GodManagerState: Int{
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}
//MARK:- 连接状态回调
public enum GodManagerConnectState: Int{
    case connect
    case failed
    case disConnect
}
//MARK:- delegate

public protocol GodManagerDelegate {
    func godManager(didDiscoverPeripheral peripheral: CBPeripheral, withRSSI RSSI: NSNumber, peripheralName name: String)
    func godManager(didUpdateCentralState state:GodManagerState)
    func godManager(didUpdateConnectState state:GodManagerConnectState,withPeripheral peripheral:CBPeripheral, withError error:Error?)
}

public final class GodManager: NSObject {
    
    private var centralManager: CBCentralManager?   //蓝牙管理中心
    fileprivate var service: CBService{
        return CBMutableService(type: MainUUID.service, primary: true)
    }                                               //蓝牙服务
    public var delegate: GodManagerDelegate?          //GodMangager代理
    
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
    //MARK:- 连接设备
    public func connect(_ peripheral:CBPeripheral){
        centralManager?.connect(peripheral, options: nil)
    }
    
}


extension GodManager: CBCentralManagerDelegate{
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            self.delegate?.godManager(didDiscoverPeripheral: peripheral, withRSSI: RSSI, peripheralName: advertisementData["kCBAdvDataLocalName"] as! String)
        }
       
    }
    
   
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {

        var state = GodManagerState(rawValue: central.state.rawValue)
        DispatchQueue.main.async {
            self.delegate?.godManager(didUpdateCentralState: state!)
        }
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
         DispatchQueue.main.async {
            self.delegate?.godManager(didUpdateConnectState: .disConnect, withPeripheral: peripheral, withError: error)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //init currentPeripheral
        PeripheralManager.share().peripheralMap[peripheral.identifier.uuidString] = peripheral
        PeripheralManager.share().UUID = peripheral.identifier.uuidString
        
        //discoverServices
        peripheral.discoverServices(nil)
//        peripheral.delegate = self
        
        //callback
        DispatchQueue.main.async {
             self.delegate?.godManager(didUpdateConnectState: .connect, withPeripheral: peripheral, withError: nil)
        }
       
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        PeripheralManager.share().peripheralMap[peripheral.identifier.uuidString] = nil
        DispatchQueue.main.async {
           self.delegate?.godManager(didUpdateConnectState: .failed, withPeripheral: peripheral, withError: error)
        }
       
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
     
    }
    
}
extension GodManager:CBPeripheralDelegate{

}
