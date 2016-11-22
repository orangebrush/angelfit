//
//  CBridgingManager+Extension.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/15.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation

extension CBridgingManager{
    
    func createBaseConfigure()  {
        //MARK:-发送健康数据命令
        swiftSendHealthDataClosure = { data,length ->Int32 in
            let sendData = Data(bytes: data, count: Int(length))
            
            guard let characteristic = PeripheralManager.share().currentPeripheralChar?[.bigWrite] else{
                return self.failure
            }
            
            guard let peripheral = PeripheralManager.share().currentPeripheral else {
                return self.failure
            }
            print("写入手环的数据:\(sendData)")
            peripheral.writeValue(sendData, for: characteristic, type: .withResponse)
            return self.success
        }
        
        //MARK:-发送命令
        swiftSendCommandDataClosure = { data,length ->Int32 in
            let sendData = Data(bytes: data, count: Int(length))
            
            guard let characteristic = PeripheralManager.share().currentPeripheralChar?[.write] else{
                return self.failure
            }
            
            guard let peripheral = PeripheralManager.share().currentPeripheral else {
                return self.failure
            }
            
            peripheral.writeValue(sendData, for: characteristic, type: .withResponse)
            return self.success
        }
        
        //MARK:- 基础功能
        swiftSendSetTime = {
            //:-设置时间（接口实现）
            AngelManager.share()?.setDate(){
                success in
            }
        }
        
        //MARK:- 设备信息回调
        swiftDeviceInfo = { data in
            
            let deviceInfo = data.assumingMemoryBound(to: protocol_device_info.self).pointee
            
            //保存数据库
            guard let macAddress = self.currentMacAddress else {
                return
            }
            
            let coreDataHandler = CoreDataHandler()
            let device = coreDataHandler.selectDevice(withMacAddress: macAddress)
            device?.bandStatus = Int16(deviceInfo.batt_status)
            device?.battLevel = Int16(deviceInfo.batt_level)
            device?.version = Int16(deviceInfo.version)
            device?.pairFlag = deviceInfo.pair_flag == 0x01 ? true : false
            device?.rebootFlag = deviceInfo.reboot_flag == 0x01 ? true : false
            device?.model = Int16(deviceInfo.mode)
            device?.deviceId = Int16(deviceInfo.device_id)
            guard coreDataHandler.commit() else{
                return
            }
        }
        
        swiftFuncTable = { data in
            
        }
        
        swiftMacAddress = { data  in
            
            let macStruct:protocol_device_mac = data.assumingMemoryBound(to: protocol_device_mac.self).pointee
            let macCList = macStruct.mac_addr
            let macList = [macCList.0, macCList.1, macCList.2, macCList.3, macCList.4, macCList.5]
            let macAddress = macList.map(){String($0,radix:16)}.reduce(""){$0+$1}.uppercased()
            self.currentMacAddress = macAddress
            
            //保存macAddress到数据库
            _ = CoreDataHandler().insertDevice(withMacAddress: macAddress)
        }
       
    }
}
