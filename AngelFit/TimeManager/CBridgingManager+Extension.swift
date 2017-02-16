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
            device?.mode = Int16(deviceInfo.mode)
            device?.deviceId = Int16(deviceInfo.device_id)
            guard coreDataHandler.commit() else{
                return
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
            let coreDataHandler = CoreDataHandler()
            _ = coreDataHandler.insertDevice(withMacAddress: macAddress)
        }
        
        swiftSyncAlarm = {
            AngelManager.share()?.setSynchronizationAlarm(closure: {
                status in
            })
        }
        swiftSetLongSit = {
            var longSitModel:LongSitModel = LongSitModel()
            
            
            let longSit = CoreDataHandler().selectLongSit(withMacAddress: self.currentMacAddress!)
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
        swiftSetUserInfo = {
            var userInfo:UserInfoModel = UserInfoModel();
            
            let user = CoreDataHandler().selectUser()
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
            userInfo.gender = UInt8((user?.gender)!)
            userInfo.height = UInt8((user?.height)!)
            userInfo.weight = UInt16(UInt8((user?.weight)!))
            let birthday = user?.birthday ?? NSDate()
            let calender = Calendar.current
            var components = calender.dateComponents([.year, .month, .day], from: birthday as! Date)
            userInfo.birthYear = UInt16(components.year!)
            userInfo.birthMonth = UInt8(components.month!)
            userInfo.birthDay = UInt8(components.day!)
            
            AngelManager.share()?.setUserInfo(userInfo, closure: {_ in
                
            })
        }
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
                AngelManager.share()?.setUnit(unitType, macAddress: self.currentMacAddress!, closure: { _ in
                    
                })
            }
        }
        
        swiftFuncTable = { data in
            
            
            let funcTableModel = data.assumingMemoryBound(to: protocol_func_table.self).pointee
            
            print("获取到功能列表: \(funcTableModel)")
            
            let funcTable = CoreDataHandler().selectDevice(withMacAddress: "MDEDSEDFTGFD")?.funcTable
            
            funcTable?.alarmCount = Int16(funcTableModel.alarm_count)
            
            funcTable?.main2_logIn = funcTableModel.main1.logIn
            
            funcTable?.main_ancs = funcTableModel.main.Ancs
            funcTable?.main_timeLine = funcTableModel.main.timeLine
            funcTable?.main_heartRate = funcTableModel.main.heartRate
            funcTable?.main_singleSport = funcTableModel.main.singleSport
            funcTable?.main_deviceUpdate = funcTableModel.main.deviceUpdate
            funcTable?.main_realtimeData = funcTableModel.main.realtimeData
            funcTable?.main_sleepMonitor = funcTableModel.main.sleepMonitor
            funcTable?.main_stepCalculation = funcTableModel.main.stepCalculation
            
            funcTable?.alarmType_custom = funcTableModel.type.custom
            funcTable?.alarmType_party = funcTableModel.type.party
            funcTable?.alarmType_sleep = funcTableModel.type.sleep
            funcTable?.alarmType_sport = funcTableModel.type.sport
            funcTable?.alarmType_dating = funcTableModel.type.dating
            funcTable?.alarmType_wakeUp = funcTableModel.type.wakeUp
            funcTable?.alarmType_metting = funcTableModel.type.metting
            funcTable?.alarmType_medicine = funcTableModel.type.medicine
            
            funcTable?.call_calling = funcTableModel.call.calling
            funcTable?.call_callingNum = funcTableModel.call.callingNum
            funcTable?.call_callingContact = funcTableModel.call.callingContact
            
            funcTable?.sport_run = funcTableModel.sport_type0.run
            funcTable?.sport_bike = funcTableModel.sport_type0.by_bike
            funcTable?.sport_foot = funcTableModel.sport_type0.on_foot
            funcTable?.sport_swim = funcTableModel.sport_type0.swim
            funcTable?.sport_walk = funcTableModel.sport_type0.walk
            funcTable?.sport_other = funcTableModel.sport_type0.other
            funcTable?.sport_climbing = funcTableModel.sport_type0.mountain_climbing
            funcTable?.sport_badminton = funcTableModel.sport_type0.badminton
            
            funcTable?.sport2_sitUp = funcTableModel.sport_type1.sit_up
            funcTable?.sport2_fitness = funcTableModel.sport_type1.fitness
            funcTable?.sport2_dumbbell = funcTableModel.sport_type1.dumbbell
            funcTable?.sport2_spinning = funcTableModel.sport_type1.spinning
            funcTable?.sport2_ellipsoid = funcTableModel.sport_type1.ellipsoid
            funcTable?.sport2_treadmill = funcTableModel.sport_type1.treadmill
            funcTable?.sport2_weightLifting = funcTableModel.sport_type1.weightlifting
            funcTable?.sport_pushUp = funcTableModel.sport_type1.push_up
            
            funcTable?.sport3_yoga = funcTableModel.sport_type2.yoga
            funcTable?.sport3_tennis = funcTableModel.sport_type2.tennis
            funcTable?.sport3_football = funcTableModel.sport_type2.footballl
            funcTable?.sport3_pingpang = funcTableModel.sport_type2.table_tennis
            funcTable?.sport3_basketball = funcTableModel.sport_type2.basketball
            funcTable?.sport3_volleyball = funcTableModel.sport_type2.volleyball
            funcTable?.sport3_ropeSkipping = funcTableModel.sport_type2.rope_skipping
            funcTable?.sport3_bodybuildingExercise = funcTableModel.sport_type2.bodybuilding_exercise
            
            funcTable?.sport4_golf = funcTableModel.sport_type3.golf
            funcTable?.sport4_dance = funcTableModel.sport_type3.dance
            funcTable?.sport4_skiing = funcTableModel.sport_type3.skiing
            funcTable?.sport4_baseball = funcTableModel.sport_type3.baseball
            funcTable?.sport4_rollerSkating = funcTableModel.sport_type3.roller_skating
            
            funcTable?.sms_tipInfoNum = funcTableModel.sms.tipInfoNum
            funcTable?.sms_tipInfoContact = funcTableModel.sms.tipInfoContact
            funcTable?.sms_tipInfoContent = funcTableModel.sms.tipInfoContent
            
            funcTable?.other_weather = funcTableModel.other.weather
            funcTable?.other_antilost = funcTableModel.other.antilost
            funcTable?.other_findPhone = funcTableModel.other.findPhone
            funcTable?.other_findDevice = funcTableModel.other.findDevice
            funcTable?.other_configDefault = funcTableModel.other.configDefault
            funcTable?.other_sedentariness = funcTableModel.other.sedentariness
            funcTable?.other_upHandGesture = funcTableModel.other.upHandGesture
            funcTable?.other_oneTouchCalling = funcTableModel.other.onetouchCalling
            
            funcTable?.other2_staticHR = funcTableModel.ohter2.staticHR
            funcTable?.other2_flipScreen = funcTableModel.ohter2.flipScreen
            funcTable?.other2_displayMode = funcTableModel.ohter2.displayMode
            funcTable?.other2_allAppNotice = funcTableModel.ohter2.allAppNotice
            funcTable?.other2_doNotDisturb = funcTableModel.ohter2.doNotDisturb
            funcTable?.other2_heartRateMonitor = funcTableModel.ohter2.heartRateMonitor
            funcTable?.other2_bilateralAntiLost = funcTableModel.ohter2.bilateralAntiLost
            
            funcTable?.control_music = funcTableModel.control.music
            funcTable?.control_takePhoto = funcTableModel.control.takePhoto
            
            funcTable?.notify_qq = funcTableModel.notify.qq
            funcTable?.notify_email = funcTableModel.notify.email
            funcTable?.notify_weixin = funcTableModel.notify.weixin
            funcTable?.notify_message = funcTableModel.notify.message
            funcTable?.notify_twitter = funcTableModel.notify.twitter
            funcTable?.notify_facebook = funcTableModel.notify.facebook
            funcTable?.notify_sinaWeibo = funcTableModel.notify.sinaWeibo
            
            funcTable?.notify2_skype = funcTableModel.ontify2.skype
            funcTable?.notify2_message = funcTableModel.ontify2.messengre
            funcTable?.notify2_calendar = funcTableModel.ontify2.calendar
            funcTable?.notify2_linkedIn = funcTableModel.ontify2.linked_in
            funcTable?.notify2_whatsapp = funcTableModel.ontify2.whatsapp
            funcTable?.notify2_instagram = funcTableModel.ontify2.instagram
            funcTable?.notify2_alarmClock = funcTableModel.ontify2.alarmClock
            
            _ = CoreDataHandler().commit()
        }
        
        //MARK:- 数据交换
        /*
          这是app发起的交换数据过程中，手环控制交换数据暂停，继续，结束 
         暂停和结束无需特殊处理，SDK需将状态传回，告诉app状态
         结束后，不仅要通知app状态，还要讲数据传回保存，并且不能再手动调用交换结束接口，否则数据已经被清除
         */
        swiftSwitchBlePause = {
        data in
            
            var ret_code:UInt32 = 0
            var reply:protocol_switch_app_ble_pause_reply = protocol_switch_app_ble_pause_reply()
            reply.err_code = 1
            let length = UInt32(MemoryLayout<UInt8>.size * 3)
            vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_BLE_PAUSE_REPLY,&reply,length,&ret_code)
            
            let pause:protocol_switch_app_ble_pause = data.assumingMemoryBound(to: protocol_switch_app_ble_pause.self).pointee
            
        }
        swiftSwitchBleRestart = {
        data in
            var ret_code:UInt32 = 0
            var reply:protocol_switch_app_ble_restore_reply = protocol_switch_app_ble_restore_reply()
            reply.err_code = 1
            let length = UInt32(MemoryLayout<UInt8>.size * 3)
            vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_BLE_RESTORE_REPLY,&reply,length,&ret_code)
            
            let reatart:protocol_switch_app_ble_restore = data.assumingMemoryBound(to: protocol_switch_app_ble_restore.self).pointee
        }
        swiftSwitchBleEnd = {
        data in
            var ret_code:UInt32 = 0
            var reply:protocol_switch_app_ble_end_reply = protocol_switch_app_ble_end_reply()
            reply.err_code = 1
            let length = UInt32(MemoryLayout<UInt8>.size * 3)
            vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_BLE_END_REPLY,&reply,length,&ret_code)
            
            let end:protocol_switch_app_ble_end = data.assumingMemoryBound(to: protocol_switch_app_ble_end.self).pointee
            
        }
        swiftBleSwitchStart = {
        data in
            let start:protocol_switch_ble_start = data.assumingMemoryBound(to: protocol_switch_ble_start.self).pointee
        }
        swiftBleSwitching = {
        data in
           let doing:protocol_switch_ble_ing = data.assumingMemoryBound(to: protocol_switch_ble_ing.self).pointee
        }
        swiftBleSwitchPause = {
        data in
            let pause:protocol_switch_ble_pause = data.assumingMemoryBound(to: protocol_switch_ble_pause.self).pointee
        }
        swiftBleSwitchRestart = {
        data in
            let start:protocol_switch_ble_restore = data.assumingMemoryBound(to: protocol_switch_ble_restore.self).pointee
        }
        swiftBleSwitchEnd = {
        data in
            let end:protocol_switch_ble_end = data.assumingMemoryBound(to: protocol_switch_ble_end.self).pointee
        }
      
        
    }
}
