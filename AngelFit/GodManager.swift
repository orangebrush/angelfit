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
    //搜索设备
    func godManager(didDiscoverPeripheral peripheral: CBPeripheral, withRSSI RSSI: NSNumber, peripheralName name: String)
    func godManager(didUpdateCentralState state:GodManagerState)
    func godManager(didUpdateConnectState state:GodManagerConnectState,withPeripheral peripheral:CBPeripheral, withError error:Error?)
    
    //连接设备
    func godManager(didConnectedPeripheral peripheral: CBPeripheral, connectState isSuccess: Bool)                  //连接完成
}

public final class GodManager: NSObject {
    
    private var centralManager: CBCentralManager?   //蓝牙管理中心
    fileprivate var service: CBService{
        return CBMutableService(type: MainUUID.service, primary: true)
    }                                               //蓝牙服务
    public var delegate: GodManagerDelegate?          //GodMangager代理
    public var isAutoReconnect: Bool = true               //自动重连
    
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = GodManager()
    public class func share() -> GodManager{
        return __once
    }
    
    //MARK:- init ----------------------------
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
    
    //连接状态改变
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {

        var state = GodManagerState(rawValue: central.state.rawValue)
        DispatchQueue.main.async {
            self.delegate?.godManager(didUpdateCentralState: state!)
        }
        
    }
    
    //连接断开
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //自动重连
        if isAutoReconnect {
            central.connect(peripheral, options: nil)
        }
        
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

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let err = error else {
            peripheral.services?.forEach(){
                service in
                peripheral.discoverCharacteristics(nil, for: service)
            }
            return
        }
        
        print("发现服务error:\n error:\(err)\n")
        DispatchQueue.main.async {
            
            let name = peripheral.name ?? ""
            
            let alertController = UIAlertController(title: "Error", message: "\(name)\n连接服务失败", preferredStyle: .alert)
            let action = UIAlertAction(title: "返回", style: .default, handler: nil)
            alertController.addAction(action)
            
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    //获取设备特征
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let err = error else{
            
            let characteristicList = service.characteristics
            
            if let characteristics = characteristicList {
                for characteristic in characteristics {
                    switch characteristic.uuid {
                    case MainUUID.read:
                        PeripheralManager.share().peripheralCharMap[peripheral.identifier.uuidString]![.read] = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                    case MainUUID.write:
                        PeripheralManager.share().peripheralCharMap[peripheral.identifier.uuidString]![.write] = characteristic
                    case MainUUID.bigWrite:
                        PeripheralManager.share().peripheralCharMap[peripheral.identifier.uuidString]![.bigWrite] = characteristic
                    case MainUUID.bigRead:
                        PeripheralManager.share().peripheralCharMap[peripheral.identifier.uuidString]![.bigRead] = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                        
                    default:
                        print("otherUUID:\(characteristic.descriptors)")
                    }
                }
            }
            
            //连接设备完成 回调
            DispatchQueue.main.async {
                
                self.delegate?.godManager(didConnectedPeripheral: peripheral, connectState: true)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.godManager(didConnectedPeripheral: peripheral, connectState: false)
        }
    }
}
