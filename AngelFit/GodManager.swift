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
@objc public enum GodManagerState: Int{
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}
//MARK:- 连接状态回调
@objc public enum GodManagerConnectState: Int{
    case connect
    case failed
    case disConnect
}
//MARK:- delegate

@objc public protocol GodManagerDelegate {
    //返回已连接设备
    func godManager(currentConnectPeripheral peripheral: CBPeripheral, peripheralName name: String)
    //搜索设备
    func godManager(didDiscoverPeripheral peripheral: CBPeripheral, withRSSI RSSI: NSNumber, peripheralName name: String)
    func godManager(didUpdateCentralState state:GodManagerState)
    func godManager(didUpdateConnectState state:GodManagerConnectState,withPeripheral peripheral:CBPeripheral, withError error:Error?)
    
    //连接设备
    func godManager(didConnectedPeripheral peripheral: CBPeripheral, connectState isSuccess: Bool)                  //连接完成
    func godManager(bindingPeripheralsUUID UUIDList:[String])           //返回已绑定设备列表
}

public final class GodManager: NSObject {
    
    fileprivate var centralManager: CBCentralManager?   //蓝牙管理中心
    fileprivate var service: CBService{
        return CBMutableService(type: MainUUID.service, primary: true)
    }                                               //蓝牙服务
    public var delegate: GodManagerDelegate?          //GodMangager代理
    public var isAutoReconnect: Bool = true               //自动重连
    fileprivate var task:TimeTask?
    
    //判断是否正在扫描
    @available(iOS 9.0, *)
    public var isScaning: Bool{
        return centralManager?.isScanning ?? false
    }
    
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
        
        //初始化蓝牙底层通讯配置
        _ = CBridgingManager.share()
        
        //初始化创建默认id=1的用户
        _ = CoreDataHandler.share().insertUser(withUserId: 1)
    }

    //Mark:- 开始扫描
    public func startScan(closure: (()->())? = nil){
        
        //判断已连接的话，添加到列表
        if let peripherals = centralManager?.retrieveConnectedPeripherals(withServices: [service.uuid]){
            for peripheral in peripherals{
                //判断UUID重复，避免重复存储
                
                centralManager?.cancelPeripheralConnection(peripheral)
//                let standardName = peripheral.name?.lowercased().replacingOccurrences(of: " ", with: "") ?? ""
                delegate?.godManager(currentConnectPeripheral: peripheral, peripheralName: peripheral.name ?? "")
            }
        }
        
        //扫描
        centralManager?.scanForPeripherals(withServices: [service.uuid], options: nil)

        //7秒后停止扫描
        _ = delay(7){
            self.stopScan()
            closure?()
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
    
    //MARK:- 断开设备
    public func disconnect(_ peripheral: CBPeripheral, closure: @escaping (Bool)->()){
        AngelManager.share()?.setBind(false, closure: closure)
        centralManager?.cancelPeripheralConnection(peripheral)
    }
}

//MARK:- 中心蓝牙管理delegate
extension GodManager: CBCentralManagerDelegate{
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //facturerData判断设备类型 目前筛选掉id为空的情况
        guard let data = advertisementData["kCBAdvDataManufacturerData"] as? Data else {
            return
        }
        
        //获取设备name
        guard let name = advertisementData["kCBAdvDataLocalName"] as? String else {
            return
        }
        
//        //获取id
//        var val: [UInt8] = Array(repeating: 0x00, count: 2)
//        (data as NSData).getBytes(&val, length: val.count)
//        
//        debugPrint("---name:\(name)--i:\(val)--data:\(data)")
        
//        let standardName = name.lowercased().replacingOccurrences(of: " ", with: "")

        DispatchQueue.main.async {
            self.delegate?.godManager(didDiscoverPeripheral: peripheral, withRSSI: RSSI, peripheralName: name)
        }
    }
    
    //连接状态改变
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {

        guard let state = GodManagerState(rawValue: central.state.rawValue) else{
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.godManager(didUpdateCentralState: state)
        }
        
        print("蓝牙状态更新: \(state.rawValue)")
        //判断蓝牙是否可用
        guard central.state == .poweredOn else {
            debugPrint("蓝牙不可用")
            cancel(task)
            return
        }
        
        //自动重连
        if isAutoReconnect{            
            debugPrint("调用重连")
            self.loop()
        }
        
    }
    
    //loop
    private func loop(){
    
        guard let peripheral = PeripheralManager.share().currentPeripheral else{
            debugPrint("未能获取到设备 重新连接...")
            
            //弹出绑定设备列表
            let uuidStringList = PeripheralManager.share().selectUUIDStringList()
            
            delegate?.godManager(bindingPeripheralsUUID: uuidStringList)
            
            
            //获取最近使用的UUID
            guard let nearUUIDString = uuidStringList.last else{
                return
            }
            
            guard let nearPeripheralUUID = UUID(uuidString: nearUUIDString) else{
                return
            }
            
            guard let peripheralList = centralManager?.retrievePeripherals(withIdentifiers: [nearPeripheralUUID]), !peripheralList.isEmpty else{
                _ = PeripheralManager.share().delete(UUIDString: nearUUIDString)
                return
            }
            
            task = delay(2){
                //...
                
                if self.isAutoReconnect{                    
                    self.connect(peripheralList[0])
                    self.loop()
                }
            }
            return
        }
        
        guard peripheral.state == .connected else {
            debugPrint("正在重连: \(peripheral)")
            
            task = delay(2){
                //...

                if self.isAutoReconnect{
                    self.connect(peripheral)
                    self.loop()
                }
            }
            return
        }
        debugPrint("设备已连接")
        cancel(task)
    }
    
    //连接断开
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        //通知设备已断开
//        var ret_code:UInt32 = 0
//        vbus_tx_evt(VBUS_EVT_BASE_APP_SET, SET_BLE_EVT_DISCONNECT, &ret_code)
        
        if peripheral.state == .disconnected{
            //发送连接失败消息
            NotificationCenter.default.post(name: disconnected_notiy, object: nil, userInfo: nil)
        }
        
        //自动重连
        if isAutoReconnect {

            debugPrint("调用重连")
            self.loop()
            
            DispatchQueue.main.async {
                
                self.delegate?.godManager(didUpdateConnectState: .disConnect, withPeripheral: peripheral, withError: error)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        debugPrint("<连接前>\(String(describing: PeripheralManager.share().UUID))连接成功<连接后>\(peripheral.identifier.uuidString)")
        cancel(task)
        
        //init currentPeripheral
        PeripheralManager.share().UUID = peripheral.identifier.uuidString                           //1.
        PeripheralManager.share().peripheralMap[peripheral.identifier.uuidString] = peripheral      //2.
        
        //discoverServices
        peripheral.discoverServices(nil)
        peripheral.delegate = self
        
        var ret_code:UInt32 = 0
        vbus_tx_evt(VBUS_EVT_BASE_APP_SET, SET_BLE_EVT_CONNECT, &ret_code)
        
        //callback
        DispatchQueue.main.async {
            //发送连接成功消息-  迁移至获取物理地址位置(需注释掉)
            NotificationCenter.default.post(name: connected_notiy, object: nil, userInfo: nil)
            
            self.delegate?.godManager(didUpdateConnectState: .connect, withPeripheral: peripheral, withError: nil)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        debugPrint("\(String(describing: peripheral.name))连接失败")
        PeripheralManager.share().peripheralMap[peripheral.identifier.uuidString] = nil
        DispatchQueue.main.async {
           self.delegate?.godManager(didUpdateConnectState: .failed, withPeripheral: peripheral, withError: error)
        }
       
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
     
    }
}

//MARK:- 设备delegate
extension GodManager:CBPeripheralDelegate{

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let err = error else {
            debugPrint("1.\(peripheral.name)发现服务成功")
            peripheral.services?.forEach(){
                service in
                peripheral.discoverCharacteristics(nil, for: service)
            }
            return
        }
        
        debugPrint("发现服务error:\n error:\(err)\n")
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
        guard error != nil else{
            
            let characteristicList = service.characteristics
            
            if let characteristics = characteristicList {
                print("2.\(String(describing: peripheral.name))发现特征成功")
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
                        print("otherUUID:\(String(describing: characteristic.descriptors))")
                    }
                }
            }
            
            //连接设备完成 回调
            DispatchQueue.main.async {
            //MARK:- 通知C库已连接上设备
//                var ret_code:UInt32 = 0
//                vbus_tx_evt(VBUS_EVT_BASE_APP_SET, SET_BLE_EVT_CONNECT, &ret_code);
                self.delegate?.godManager(didConnectedPeripheral: peripheral, connectState: true)
                
            }
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.godManager(didConnectedPeripheral: peripheral, connectState: false)
        }
    }
    
    //MARK:- 接收数据
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let data = characteristic.value else {
            return
        }
        
        let length = (data as NSData).length
        
        var val: [UInt8] = Array(repeating: 0x00, count: 20)
        (data as NSData).getBytes(&val, length: length)
        protocol_receive_data(val,UInt16(length))
        print("3.\(String(describing: peripheral.name))接收蓝牙数据成功 \n \(val)")
    }
}
