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
    private static var __once: AngelSwitchDataManager? {
        return AngelSwitchDataManager()
    }
    public class func share() -> AngelSwitchDataManager?{
        return __once
    }
    private let angelManager = AngelManager.share()
    private var macAddress : String?
    
    override init(){
    super.init()
        //初始化获取macAddress
        angelManager?.getMacAddressFromBand(){
            errorCode, data in
            if errorCode == ErrorCode.success{
                self.macAddress = data
            }
        }
    }
    // MARK:- app发起交换数据
    //开始交换数据
    public func appSwitchStart( withParam start:SwitchStart , macAddress: String? = nil, closure:@escaping (_ success:Bool ,_ bleState:UInt8 )->()){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: start.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: startDate!)
        
        
        var switchStart = protocol_switch_app_start()
        switchStart.start_time.day   = UInt8(components.day!)
        switchStart.start_time.hour = UInt8(components.hour!) 
        switchStart.start_time.minute = UInt8(components.minute!)
        switchStart.start_time.second = UInt8(components.second!)
        switchStart.sport_type = start.sportType 
        switchStart.target_type = start.targetType 
        switchStart.target_value = UInt32(start.targetValue) 
        switchStart.force_start = start.forceStart 
        let length = UInt32(MemoryLayout<UInt8>.size * 9) + UInt32(MemoryLayout<UInt32>.size)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_STAERT,&switchStart,length,&ret_code)
        guard ret_code == 0 else {
            closure(false,0) 
            return
        }
        swiftSwitchStartReply = {
            data in
            let startReply:protocol_switch_app_start_reply = data.assumingMemoryBound(to: protocol_switch_app_start_reply.self).pointee
            closure(true , startReply.ret_code)
         
        }
    }
    //交换数据中
    public func appSwitchDoing (withParam doing:SwitchDoing , macAddress: String? = nil, closure:@escaping (_ success:Bool,_ reply:SwitchDoingReply )->()){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: doing.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: startDate!)
        
        
        var switchDoing = protocol_switch_app_ing()
        switchDoing.start_time.day   = UInt8(components.day!)
        switchDoing.start_time.hour = UInt8(components.hour!) 
        switchDoing.start_time.minute = UInt8(components.minute!)
        switchDoing.start_time.second = UInt8(components.second!)
        switchDoing.calories = doing.calories
        switchDoing.distance = doing.distance
        switchDoing.duration = doing.duration
        switchDoing.flag = doing.flag 
        let length = UInt32(MemoryLayout<UInt8>.size * 7) + UInt32(MemoryLayout<UInt32>.size * 3)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_ING,&switchDoing,length,&ret_code)
        guard ret_code == 0 else {
            closure(false,SwitchDoingReply()) 
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
            switchReply.hrValueSerial = doingReply.hr_item.hr_value_serial 
            switchReply.intervalSecond = doingReply.hr_item.interval_second 
            if switchReply.intervalSecond > 0 {
                  switchReply.hrValue = doingReply.hr_item.hr_vlaue 
            }
            closure(true,switchReply)
        }
    }
    //交换数据暂停
    public func appSwitchingPause (withParam pause:SwitchPauseOrContinue , macAddress: String? = nil, closure:@escaping (_ success:Bool)->()){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: pause.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: startDate!)
        
        var switchPause = protocol_switch_app_pause()
        switchPause.start_time.day   = UInt8(components.day!)
        switchPause.start_time.hour = UInt8(components.hour!) 
        switchPause.start_time.minute = UInt8(components.minute!)
        switchPause.start_time.second = UInt8(components.second!)
        let length = UInt32(MemoryLayout<UInt8>.size * 6)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_PAUSE,&switchPause,length,&ret_code)
        
        guard ret_code == 0 else {
            closure(false)
            return
        }
        swiftSwitchPauseReply = {
        data in
            let pause:protocol_switch_app_pause_reply = data.assumingMemoryBound(to: protocol_switch_app_pause_reply.self).pointee
            guard pause.err_code == 0 else {
                closure(false)
                return
            }
            closure(true)
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
        switchEnd.is_save = UInt8(end.isSave)
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
}
