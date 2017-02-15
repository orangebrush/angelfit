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
    public func appSwitchStart( withParam start:SwitchStart , macAddress: String? = nil, closure:@escaping (_ success:Bool)->()){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: start.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: startDate!)
        
        
        var switchStart = protocol_switch_app_start()
        switchStart.start_time.day   = UInt8(components.day!)
        switchStart.start_time.hour = UInt8(components.hour!);
        switchStart.start_time.minute = UInt8(components.minute!)
        switchStart.start_time.second = UInt8(components.second!)
        switchStart.sport_type = start.sportType;
        switchStart.target_type = start.targetType;
        switchStart.target_value = UInt32(start.targetValue);
        switchStart.force_start = start.forceStart;
        let length = UInt32(MemoryLayout<UInt8>.size * 9) + UInt32(MemoryLayout<UInt32>.size)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_STAERT,&switchStart,length,&ret_code);
    }
    //交换数据中
    public func appSwitchDoing (withParam doing:SwitchDoind , macAddress: String? = nil, closure:@escaping (_ success:Bool)->()){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let startDate = dateFormatter.date(from: doing.timeString)
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: startDate!)
        
        
        var switchDoing = protocol_switch_app_ing()
        switchDoing.start_time.day   = UInt8(components.day!)
        switchDoing.start_time.hour = UInt8(components.hour!);
        switchDoing.start_time.minute = UInt8(components.minute!)
        switchDoing.start_time.second = UInt8(components.second!)
        switchDoing.calories = doing.calories
        switchDoing.distance = doing.distance
        switchDoing.duration = doing.duration
        switchDoing.flag = doing.flag;
        let length = UInt32(MemoryLayout<UInt8>.size * 7) + UInt32(MemoryLayout<UInt32>.size * 3)
        var  ret_code : UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_STAERT,&switchDoing,length,&ret_code);
    }
    //交换数据暂停
    public func appSwitchingPause (withParam pause:SwitchDoind , macAddress: String? = nil, closure:@escaping (_ success:Bool)->())
    //交换数据继续
    //交换数据结束
}
