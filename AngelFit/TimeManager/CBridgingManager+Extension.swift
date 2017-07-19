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
            
            guard PeripheralManager.share().currentPeripheral?.state == .connected else {
                return self.failure
            }
            
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
            
            guard PeripheralManager.share().currentPeripheral?.state == .connected else {
                return self.failure
            }
            
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
            
//            let deviceInfo = data.assumingMemoryBound(to: protocol_device_info.self).pointee
//            
//            //保存数据库
//            guard let macAddress = self.currentMacAddress else {
//                return
//            }
//            
//            let coreDataHandler = CoreDataHandler.share()
//            let device = coreDataHandler.selectDevice(withAccessoryId: macAddress)
//            device?.bandStatus = Int16(deviceInfo.batt_status)
//            device?.battLevel = Int16(deviceInfo.batt_level)
//            device?.version = Int16(deviceInfo.version)
//            device?.pairFlag = deviceInfo.pair_flag == 0x01 ? true : false
//            device?.rebootFlag = deviceInfo.reboot_flag == 0x01 ? true : false
//            device?.mode = Int16(deviceInfo.mode)
//            device?.deviceId = Int16(deviceInfo.device_id)
//            guard coreDataHandler.commit() else{
//                return
//            }
            let deviceInfo = data.assumingMemoryBound(to: protocol_device_info.self).pointee
            
            let deviceId = "\(deviceInfo.device_id)"
            
            //当设备物理地址存在时，插入设备项
            if let macAddress = self.currentMacAddress {
                let accessoryId = "1" + macAddress + deviceId
                self.currentMacAddress = accessoryId
                
                let coredataHandler = CoreDataHandler.share()
                let device = coredataHandler.insertDevice(withAccessoryId: accessoryId, byUserId: UserManager.share().userId)
                device?.batteryStatus = Int16(deviceInfo.batt_status)
                device?.batteryLevel = Int16(deviceInfo.batt_level)
                _ = Int16(deviceInfo.version)
                device?.isPaired = deviceInfo.pair_flag == 0x01 ? true : false
                device?.isRebooted = deviceInfo.reboot_flag == 0x01 ? true : false
                device?.runMode = Int16(deviceInfo.mode)
                device?.accessoryId = accessoryId
           
                guard coredataHandler.commit() else{
                    return
                }
            }
        }
        
        swiftMacAddress = { data  in
            
            let macStruct:protocol_device_mac = data.assumingMemoryBound(to: protocol_device_mac.self).pointee
            
            print("获取到Mac地址:\(macStruct)")
            let macCList = macStruct.mac_addr
            let macList = [macCList.0, macCList.1, macCList.2, macCList.3, macCList.4, macCList.5]
            let macAddress = macList.map(){String($0,radix:16)}.reduce(""){$0+$1}.uppercased()
            self.currentMacAddress = macAddress
            AngelManager.share()?.macAddress = macAddress
            //保存macAddress到数据库
            let coreDataHandler = CoreDataHandler.share()
            _ = coreDataHandler.insertDevice(withAccessoryId: macAddress)
        }
        /*
        swiftSyncAlarm = {
            AngelManager.share()?.setSynchronizationAlarm(closure: {
                status in
            })
        }
        swiftSetLongSit = {
            var longSitModel:LongSitModel = LongSitModel()
            
            guard let macaddress = self.currentMacAddress else {
                return
            }
            let longSit = CoreDataHandler.share().selectLongSit(withMacAddress: macaddress)
            guard (longSit != nil) else {
                longSitModel.startHour = UInt8(9)
                longSitModel.startMinute = UInt8(0)
                longSitModel.endHour = UInt8(21)
                longSitModel.endMinute = UInt8(0)
                longSitModel.isOpen = false
                longSitModel.duringTime = 0
                longSitModel.weekdayList = [Int]()
                
                AngelManager.share()?.setLongSit(longSitModel, closure: {_ in
                    
                })
                
                return
            }
            let calender = Calendar.current
            var components = calender.dateComponents([.hour,.minute], from: longSit?.startDate as! Date)
            longSitModel.startHour = UInt8(components.hour!)
            longSitModel.startMinute = UInt8(components.minute!)
            
            components = calender.dateComponents([.hour,.minute], from: longSit?.endDate as! Date)
            longSitModel.endHour = UInt8(components.hour!)
            longSitModel.endMinute = UInt8(components.minute!)
            
            longSitModel.isOpen = (longSit?.isOpen)!
            longSitModel.duringTime = UInt16((longSit?.interval)!)
            longSitModel.weekdayList = (longSit?.weekdayList)! as! [Int]
            
            AngelManager.share()?.setLongSit(longSitModel, closure: {_ in
                
            })
            
        }
         */
        
        /*
        swiftSetUserInfo = {
            let userInfo: UserInfoModel = UserInfoModel();
            
            let userId = UserManager.share().userId
            let user = CoreDataHandler.share().selectUser(withUserId: userId)
            guard user != nil else {
                userInfo.gender = 0
                userInfo.height = 175
                userInfo.weight = 65*100
                userInfo.birthYear = 1991
                userInfo.birthMonth = 1
                userInfo.birthDay = 1
                
                AngelManager.share()?.setUserInfo(userInfo, closure: {_ in
                    
                })
                return
            }
            userInfo.gender = UInt8((user?.userInfo?.gender)!)
            userInfo.height = UInt8((user?.height)!)
            userInfo.weight = UInt16((user?.currentWeight)!)
            let birthday = user?.birthday ?? NSDate()
            let calender = Calendar.current
            var components = calender.dateComponents([.year, .month, .day], from: birthday as Date)
            userInfo.birthYear = UInt16(components.year!)
            userInfo.birthMonth = UInt8(components.month!)
            userInfo.birthDay = UInt8(components.day!)
            
            AngelManager.share()?.setUserInfo(userInfo, closure: {_ in
                
            })
        }
        */
        
        /*
        swiftSetUnit = {
            AngelManager.share()?.getUnit(){
                unit in
                
                var unitType: Set<UnitType> = [.distance_KM, .langure_ZH, .temp_C, .timeFormat_24, .weight_KG]
                
                if unit?.distance == 0x02{
                    unitType.insert(UnitType.distance_MI)
                }
                if unit?.language == 0x02{
                    unitType.insert(UnitType.langure_ZH)
                }
                if unit?.weight == 0x02{
                    unitType.insert(UnitType.weight_LB)
                }
                if unit?.temperature == 0x02{
                    unitType.insert(UnitType.temp_F)
                }
                if unit?.timeFormat == 0x02{
                    unitType.insert(UnitType.timeFormat_12)
                }
                if let macaddress = self.currentMacAddress{
                    AngelManager.share()?.setUnit(unitType, macAddress: macaddress, closure: { _ in
                        
                    })
                }
            }
        }
         */
        
        swiftFuncTable = { data in
            
            guard let accessoryId = self.currentAccessoryId else {
                return
            }
            debug("--------------\n已经获取funcTable")
            
            let funcTableModel = data.assumingMemoryBound(to: protocol_func_table.self).pointee
            
            let coredataHandler = CoreDataHandler.share()
            let device = coredataHandler.selectDevice(withAccessoryId: accessoryId, byUserId: UserManager.share().userId)
            let deviceFunction = device?.deviceFunction
            
            deviceFunction?.haveAlarm = funcTableModel.alarm_count > 0
            deviceFunction?.haveAllMsgNotification = funcTableModel.ohter2.allAppNotice
            deviceFunction?.haveAncs = funcTableModel.main.Ancs
            deviceFunction?.haveAntiLost = funcTableModel.ohter2.bilateralAntiLost
            deviceFunction?.haveCallNumber = funcTableModel.call.callingNum
            deviceFunction?.haveCallContact = funcTableModel.call.callingContact
            deviceFunction?.haveCallNotification = funcTableModel.call.calling
            deviceFunction?.haveCameraControl = funcTableModel.control.takePhoto
            deviceFunction?.haveFindPhone = funcTableModel.other.findPhone
            deviceFunction?.haveHeartRateMonitor = funcTableModel.ohter2.heartRateMonitor
            deviceFunction?.haveHeartRateMonitorControl = true
            deviceFunction?.haveLogin = funcTableModel.main1.logIn
            deviceFunction?.haveLongSit = true
            deviceFunction?.haveMsgContent = funcTableModel.sms.tipInfoContact
            deviceFunction?.haveMultiSport = true
            deviceFunction?.haveNotDisturbMode = funcTableModel.ohter2.doNotDisturb
            deviceFunction?.haveOta = true
            deviceFunction?.havePedometer = true
            deviceFunction?.havePlayMusicControl = funcTableModel.control.music
            deviceFunction?.haveRealData = funcTableModel.main.realtimeData
            deviceFunction?.haveScreenDisplay180Rotate = true
            deviceFunction?.haveScreenDisplayMode = funcTableModel.ohter2.displayMode
            deviceFunction?.haveShortcutCall = funcTableModel.other.onetouchCalling
            deviceFunction?.haveShortcutReset = true
            deviceFunction?.haveSleepMonitor = funcTableModel.main.sleepMonitor
            deviceFunction?.haveTimeline = funcTableModel.main.timeLine
            deviceFunction?.haveTraininTracking = true
            deviceFunction?.haveWakeScreenOnWristRaise = true
            deviceFunction?.haveWeatherForecast = funcTableModel.other.weather
            deviceFunction?.isHeartRateMonitorSilent = funcTableModel.ohter2.staticHR
            
            
            _ = coredataHandler.commit()
        }
    }
}
