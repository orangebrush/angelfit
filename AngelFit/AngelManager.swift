//
//  AngelManager.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/7.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//
/*
 用于给设备发送指令
 */

import Foundation
import CoreBluetooth
public class AngelManager: NSObject {
    
    enum ActionType {
        case binding    //绑定
        case unbinding  //解绑
        case responceType //回复活动状态
        case activated  //实时数据请求
    }
    
    var actionMap:[ActionType:[UInt8]]?{
        let map:[ActionType:[UInt8]] = [.binding:[0x04, 0x01, 0x01, 0x83, 0x55, 0xaa],
                                        .unbinding:[0x04, 0x02, 0x55, 0xaa, 0x55, 0xaa],
                                        .responceType:[0x07, 0xA1, 0x01],
                                        .activated:[0x02, 0xA1]]
        return map
    }
    private var peripheral: CBPeripheral?
    
    //MARK:- init +++++++++++++++++++
    private static var __once: AngelManager? {
        guard let peripheral = PeripheralManager.share().currentPeripheral else{
            return nil
        }
        return AngelManager(currentPeripheral: peripheral)
    }
    class func share() -> AngelManager?{
        return __once
    }
    
    init(currentPeripheral existPeripheral: CBPeripheral) {
        super.init()
        
        peripheral = existPeripheral
        
        config()
    }
    
    private func config(){
        
    }
    
    func write(withActionType actionType:ActionType, writeType:CBCharacteristicWriteType = .withResponse){
        
        guard peripheral?.state == CBPeripheralState.connected else {
            return
        }
        
        guard var val = actionMap![actionType] else{
            return
        }
        
        //多类型实时数据，需添加动作类型
        if actionType == .activated{
            val.append(0x01)
        }
        
        while val.count < 20 {
            val.append(0x00)
        }
        let data = Data(bytes: UnsafePointer<UInt8>(val), count: val.count)
        
        if let characteristic = PeripheralManager.share().currentPeripheralChar?[.write]{
            peripheral?.writeValue(data, for: characteristic, type: writeType)
        }
    }
    
    //MARK:自定义写入
    public func write(withValue value:[UInt8]){
        
        var val = [UInt8](value)
        
        while val.count < 20 {
            val.append(0x00)
        }
        let data = Data(bytes: UnsafePointer<UInt8>(val), count: val.count)
        
        if let characteristic = PeripheralManager.share().currentPeripheralChar?[.write]{
            peripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    /*
     API
     */
    
    //固件升级
    public func updateDevice(closure: (_ success: Bool)->()){
        
    }
}

extension AngelManager: CBPeripheralDelegate{
    //指令返回
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        characteristic.value
    }
}
