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
extension AngelManager {
    
   
    

    
//    func write(withActionType actionType:ActionType, writeType:CBCharacteristicWriteType = .withResponse){
//        
//        guard peripheral.state == CBPeripheralState.connected else {
//            return
//        }
//        
//        guard var val = actionMap![actionType] else{
//            return
//        }
//        
//        //多类型实时数据，需添加动作类型
//        if actionType == .activated{
//            val.append(0x01)
//        }
//        
//        while val.count < 20 {
//            val.append(0x00)
//        }
//        let data = Data(bytes: UnsafePointer<UInt8>(val), count: val.count)
//        
//        if let characteristic = PeripheralManager.share().currentPeripheralChar?[.write]{
//            peripheral?.writeValue(data, for: characteristic, type: writeType)
//        }
//    }
    
    //MARK:自定义写入
//    public func write(withValue value:[UInt8]){
//        
//        var val = [UInt8](value)
//        
//        while val.count < 20 {
//            val.append(0x00)
//        }
//        let data = Data(bytes: UnsafePointer<UInt8>(val), count: val.count)
//        
//        if let characteristic = PeripheralManager.share().currentPeripheralChar?[.write]{
//            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
//        }
//    }
}

//extension AngelManager: CBPeripheralDelegate{
//    //指令返回
//    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        
//        characteristic.value
//    }
//}
