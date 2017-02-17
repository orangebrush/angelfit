//
//  AngelSwitchDataManager.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2017/2/10.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth
class AngelSwitchDataManager: NSObject {
    private static var __once: () = {
        singleton.instance = AngelSwitchDataManager()
    }()
    struct singleton{
        static var instance:AngelSwitchDataManager? = nil
    }
    public class func share() -> AngelSwitchDataManager?{
        _ = AngelSwitchDataManager.__once
        return singleton.instance
    }
//    private lazy var angelManager: AngelManager? = {
//        return AngelManager.share()
//    }()
    
    // MARK:- app发起交换数据
    //开始交换数据
    public func appSwitchStart( withParam start:SwitchStart , macAddress: String? = nil, closure:@escaping (_ errorCode: Int16, _ reason: Int16?)->()){
        
        guard let peripheral = PeripheralManager.share().currentPeripheral else{
            closure(ErrorCode.failure, nil)
            return
        }
        
        guard peripheral.state == .connected else {
            closure(ErrorCode.failure, nil)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: start.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: startDate!)
        
        
        var switchStart = protocol_switch_app_start()
        switchStart.start_time.day   = UInt8(components.day!)
        switchStart.start_time.hour = UInt8(components.hour!) 
        switchStart.start_time.minute = UInt8(components.minute!)
        switchStart.start_time.second = UInt8(components.second!)
        switchStart.sport_type = start.sportType                //运动类型
        switchStart.target_type = start.targetType              //目标类型
        switchStart.target_value = UInt32(start.targetValue)    //目标值
        switchStart.force_start = start.forceStart              //强制开始
        let length = UInt32(MemoryLayout<UInt8>.size * 9) + UInt32(MemoryLayout<UInt32>.size)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_STAERT,&switchStart,length,&ret_code)
        guard ret_code == 0 else {
            closure(ErrorCode.failure, nil)
            return
        }
        swiftSwitchStartReply = {
            data in
            let startReply:protocol_switch_app_start_reply = data.assumingMemoryBound(to: protocol_switch_app_start_reply.self).pointee
            //0x00:成功; 0x01:设备已经进入运动模式失败;0x02: 设备电量低失败
            closure(ErrorCode.success, Int16(startReply.ret_code))
        }
    }
    //交换数据中
    public func appSwitchDoing (withParam doing:SwitchDoing , macAddress: String? = nil, closure:@escaping (_ errorCode:Int16,_ reply:SwitchDoingReply?)->()){
        
        guard let peripheral = PeripheralManager.share().currentPeripheral else{
            closure(ErrorCode.failure, nil)
            return
        }
        
        guard peripheral.state == .connected else {
            closure(ErrorCode.failure, nil)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: doing.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: startDate!)
        var switchDoing = protocol_switch_app_ing()
        switchDoing.start_time.day   = UInt8(components.day!)
        switchDoing.start_time.hour = UInt8(components.hour!) 
        switchDoing.start_time.minute = UInt8(components.minute!)
        switchDoing.start_time.second = UInt8(components.second!)
        switchDoing.calories = doing.calories
        switchDoing.distance = doing.distance
        switchDoing.duration = doing.duration
        switchDoing.flag = doing.flag               //
        let length = UInt32(MemoryLayout<UInt8>.size * 7) + UInt32(MemoryLayout<UInt32>.size * 3)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_ING,&switchDoing,length,&ret_code)
        guard ret_code == 0 else {
            closure(ErrorCode.failure, nil)
            return
        }
        
        swiftSwitchingReply = {
        data in
            let doingReply:protocol_switch_app_ing_reply = data.assumingMemoryBound(to: protocol_switch_app_ing_reply.self).pointee
            let switchReply:SwitchDoingReply = SwitchDoingReply()
            switchReply.calories = doingReply.calories
            switchReply.distance = doingReply.distance
            switchReply.step = doingReply.step
            switchReply.curHrValue = doingReply.hr_item.cur_hr_value
            switchReply.hrValueSerial = doingReply.hr_item.hr_value_serial          //.1
            switchReply.intervalSecond = doingReply.hr_item.interval_second         //5s
            if switchReply.intervalSecond > 0 {
                switchReply.hrValue = doingReply.hr_item.hr_vlaue
            }
            closure(ErrorCode.success, switchReply)
        }
    }
    //交换数据暂停
    public func appSwitchingPause (withParam pause:SwitchPauseOrContinue , macAddress: String? = nil, closure:@escaping (_ errorCode: Int16)->()){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: pause.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: startDate!)
        
        var switchPause = protocol_switch_app_pause()
        switchPause.start_time.day   = UInt8(components.day!)
        switchPause.start_time.hour = UInt8(components.hour!) 
        switchPause.start_time.minute = UInt8(components.minute!)
        switchPause.start_time.second = UInt8(components.second!)
        let length = UInt32(MemoryLayout<UInt8>.size * 6)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_PAUSE,&switchPause,length,&ret_code)
        
        guard ret_code == 0 else {
            closure(ErrorCode.failure)
            return
        }
        swiftSwitchPauseReply = {
        data in
            let pause:protocol_switch_app_pause_reply = data.assumingMemoryBound(to: protocol_switch_app_pause_reply.self).pointee
            guard pause.err_code == 0 else {
                closure(ErrorCode.failure)
                return
            }
            closure(ErrorCode.success)
        }
    }
    //交换数据继续
    public func appSwitchRestart (withParam restart:SwitchPauseOrContinue , macAddress: String? = nil, closure:@escaping (_ success:Bool)->()){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: restart.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: startDate!)
        var switchRestart = protocol_switch_app_pause()
        switchRestart.start_time.day   = UInt8(components.day!)
        switchRestart.start_time.hour = UInt8(components.hour!) 
        switchRestart.start_time.minute = UInt8(components.minute!)
        switchRestart.start_time.second = UInt8(components.second!)
        let length = UInt32(MemoryLayout<UInt8>.size * 6)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_RESTORE,&switchRestart,length,&ret_code)
        
        guard ret_code == 0 else {
            closure(false)
            return
        }
        swiftSwitchRestartReply = {
            data in
            let restart:protocol_switch_app_restore_reply = data.assumingMemoryBound(to: protocol_switch_app_restore_reply.self).pointee
            guard restart.err_code == 0 else {
                closure(false)
                return
            }
            closure(true)
        }

    }
    //交换数据结束
    public func appSwitchEnd (withParam end:SwitchEnd , macAddress: String? = nil, closure:@escaping (_ success:Bool ,_ endReply:SwitchEndReply )->()){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: end.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: startDate!)
        
        
        var switchEnd = protocol_switch_app_end()
        switchEnd.start_time.day   = UInt8(components.day!)
        switchEnd.start_time.hour = UInt8(components.hour!) 
        switchEnd.start_time.minute = UInt8(components.minute!)
        switchEnd.start_time.second = UInt8(components.second!)
        switchEnd.calories = end.calories
        switchEnd.distance = end.distance
        switchEnd.durations = end.durations
        switchEnd.sport_type = UInt8(end.sportType)
        switchEnd.is_save = UInt8(end.isSave)           // < 10m false
        let length = UInt32(MemoryLayout<UInt8>.size * 7) + UInt32(MemoryLayout<UInt32>.size * 3)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_END,&switchEnd,length,&ret_code)
        
        guard ret_code == 0 else {
            closure(false,SwitchEndReply())
            return
        }
        swiftSwitchEndReply = {
        data in
            let switchEndStruct:protocol_switch_app_end_reply = data.assumingMemoryBound(to: protocol_switch_app_end_reply.self).pointee
            let endRelpyResult = SwitchEndReply()
            endRelpyResult.errCode = switchEndStruct.err_code
            endRelpyResult.step = switchEndStruct.step
            endRelpyResult.calories = switchEndStruct.calories
            endRelpyResult.distance = switchEndStruct.distance
            endRelpyResult.avgHrValue = switchEndStruct.hr_value.avg_hr_value
            endRelpyResult.maxHrValue = switchEndStruct.hr_value.max_hr_value
            endRelpyResult.burnFatMins = switchEndStruct.hr_value.burn_fat_mins
            endRelpyResult.aerobicMins = switchEndStruct.hr_value.aerobic_mins
            endRelpyResult.limitMins = switchEndStruct.hr_value.limit_mins
            closure(true,endRelpyResult)
        }
    }
    //同步活动数据
    public func setSynchronizationActiveData(_ macAddress: String? = nil, closure:@escaping (_ complete: Bool, _ progress: Int16 ,_ timeOut:Bool) -> ()){
        swiftSyncActiveProgress = {
            /*data为同步百分比 */
            data in
            closure(false,Int16(data),false);
        }
        swiftSyncActiveComplete = {
        closure(true,100,false)
        }
        swiftSyncActiveTimeOut = {
          closure(false,0,true)
        }
        swiftSyncActiveData = {
        data in
            let activeData:protocol_activity_data = data.assumingMemoryBound(to: protocol_activity_data.self).pointee
        }
        
    }
    //获取同步项个数
    public func getSynchronizationActiveCount(_ macAddress: String? = nil, closure:@escaping (_ count: UInt8) -> ()){
        var ret_code:UInt32 = 0;
        vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_ACTIVITY_COUNT,&ret_code);

        swiftGetActiveCount = {
            data in
            let activeCount:protocol_new_health_activity_count = data.assumingMemoryBound(to: protocol_new_health_activity_count.self).pointee
            closure(activeCount.count)
        }

    }
    //回复手环端发起的请求
    public func sendSwitchStart(_ retCode:Int){
        var ret_code:UInt32 = 0
        var reply:protocol_switch_ble_start_reply = protocol_switch_ble_start_reply();
        reply.ret_code = UInt8(retCode);
        let length = UInt32(MemoryLayout<UInt8>.size * 3)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_BLE_START_REPLY,&reply,length,&ret_code);
        
    }
    public func sendSwitchPause(_ retCode:Int){
        var ret_code:UInt32 = 0
        var reply:protocol_switch_ble_pause_reply = protocol_switch_ble_pause_reply();
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        reply.ret_code = UInt8(retCode);

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_BLE_PAUSE_REPLY,&reply,length,&ret_code);
        
    }
    public func sendSwitchRestart(_ retCode:Int){
        var ret_code:UInt32 = 0
        var reply:protocol_switch_ble_restore_reply = protocol_switch_ble_restore_reply();
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        reply.ret_code = UInt8(retCode);

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_BLE_RESTORE_REPLY,&reply,length,&ret_code);
        
    }
    public func sendSwitchEnd(_ retCode:Int){
        var ret_code:UInt32 = 0
        var reply:protocol_switch_ble_end_reply = protocol_switch_ble_end_reply();
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        reply.ret_code = UInt8(retCode);

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_BLE_END_REPLY,&reply,length,&ret_code);
        
    }
    public func sendSwitchDoing(_ distance:Int){
        var ret_code:UInt32 = 0
        var reply:protocol_switch_ble_ing_reply = protocol_switch_ble_ing_reply();
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        reply.distance = UInt32(distance);
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_BLE_ING_REPLY,&reply,length,&ret_code);
        
    }
    
}
