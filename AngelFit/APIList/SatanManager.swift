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
import CoreLocation
//MARK:- 数据交换状态
@objc public enum SatanManagerState: Int{
    case start = 0
    case pause
    case restore
    case end
}

@objc public protocol SatanManagerDelegate {
    func satanManager(didUpdateState state: SatanManagerState)              //状态(主要控制定位)
    func satanManagerDistanceByLocation(withBleDistance distance: UInt32) -> UInt32                            //返回手机定位距离
    func satanManagerDuration() -> Int                                      //返回手机持续时间
    func satanManager(didSwitchingReplyCalories calories: UInt32, distance: UInt32, step: UInt32, curHeartrate: UInt8, heartrateSerial: UInt8, available: Bool, heartrateValue: [UInt8])
}

public class SatanManager: NSObject {
    
    //delegate
    public weak var delegate: SatanManagerDelegate?
    
    private let calendar = Calendar.current
    
    //存储当前活动开始日期
    private var curDate: Date?
    
    //MARK:- 获取数据库句柄
    private lazy var coredataHandler = {
        return CoreDataHandler.share()
    }()
    
    //MARK:- 获取AngelManager
    private var angelManager: AngelManager?{
        return AngelManager.share()
    }
    
    //MARK:- init
    private static var __once: () = {
        singleton.instance = SatanManager()
    }()
    struct singleton{
        static var instance:SatanManager? = nil
    }
    public class func share() -> SatanManager?{
        _ = SatanManager.__once
        return singleton.instance
    }
    
    //MARK:- 判断是否设备是否连接
    private func isPeripheralConnected() -> Bool{
        guard let peripheral = PeripheralManager.share().currentPeripheral else{
            return false
        }
        
        guard peripheral.state == .connected else {
            return false
        }
        return true
    }
    
    //MARK:- init
    override init() {
        super.init()
        
        initDelegate()
    }
    
    //MARK:- delegate
    private func initDelegate(){
        //MARK:- 数据交换
        /*
         app发起--手环操作
         这是app发起的交换数据过程中，手环控制交换数据暂停，继续，结束
         暂停和结束无需特殊处理，SDK需将状态传回，告诉app状态
         结束后，不仅要通知app状态，还要将数据传回保存，并且不能再手动调用交换结束接口，否则数据将被清除
         */
        swiftSwitchBlePause = {
            data in
            
            var ret_code: UInt32 = 0
            var reply: protocol_switch_app_ble_pause_reply = protocol_switch_app_ble_pause_reply()
            reply.err_code = 1
            let length = UInt32(MemoryLayout<UInt8>.size * 3)
            vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_BLE_PAUSE_REPLY, &reply, length, &ret_code)
            
            //let pause: protocol_switch_app_ble_pause = data.assumingMemoryBound(to: protocol_switch_app_ble_pause.self).pointee
            //暂停定位
            DispatchQueue.main.async {
                self.delegate?.satanManager(didUpdateState: .pause)
            }
        }
        swiftSwitchBleRestore = {
            data in
            var ret_code:UInt32 = 0
            var reply:protocol_switch_app_ble_restore_reply = protocol_switch_app_ble_restore_reply()
            reply.err_code = 1
            let length = UInt32(MemoryLayout<UInt8>.size * 3)
            vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_BLE_RESTORE_REPLY, &reply, length, &ret_code)
            
            //let restore: protocol_switch_app_ble_restore = data.assumingMemoryBound(to: protocol_switch_app_ble_restore.self).pointee
            //恢复定位
            DispatchQueue.main.async {
                self.delegate?.satanManager(didUpdateState: .restore)
            }
        }
        swiftSwitchBleEnd = {
            data in
            
            self.curDate = nil
            
            var ret_code: UInt32 = 0
            var reply: protocol_switch_app_ble_end_reply = protocol_switch_app_ble_end_reply()
            reply.err_code = 1
            let length = UInt32(MemoryLayout<UInt8>.size * 3)
            vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SWITCH_APP_BLE_END_REPLY, &reply, length, &ret_code)
            
            //结束定位
            DispatchQueue.main.async {
                self.appSwitch(flag: false)
                self.delegate?.satanManager(didUpdateState: .end)
            }

            //数据库操作
            let end: protocol_switch_app_ble_end = data.assumingMemoryBound(to: protocol_switch_app_ble_end.self).pointee
            let isSave = end.is_save == 0x01 ? true : false
            guard let date = self.curDate, let macaddress = self.angelManager?.macAddress else {
                return
            }
            if isSave {
                //存储
                let calories = end.calories
                let step = end.step
                let distance = end.distance
                let hrValue = end.hr_value
                
                let userId = UserManager.share().userId
                guard let track = self.coredataHandler.selectTrack(userId: userId, withMacAddress: macaddress, withDate: date, withDayRange: nil).last else {
                    return
                }
                track.date = date as NSDate?
                track.step = Int16(step)
                track.aerobicMinutes = Int16(hrValue.aerobic_mins)
                track.avgrageHeartrate = Int16(hrValue.avg_hr_value)
                track.burnFatMinutes = Int16(hrValue.burn_fat_mins)
                track.calories = Int16(calories)
                track.distance = Double(distance)
                guard self.coredataHandler.commit() else {
                    return
                }
            }else{
                //删除当天最后一条交换数据
                let userId = UserManager.share().userId
                self.coredataHandler.deleteTrack(userId: userId, withMacAddress: macaddress, withDate: date)
            }
        }
        
        //手环发起--手环操作
        /*  添加回复接口*/
        swiftBleSwitchStart = {
            data in
            //let start: protocol_switch_ble_start = data.assumingMemoryBound(to: protocol_switch_ble_start.self).pointee
            self.sendSwitchStart(0x01)
            //开始定位
            DispatchQueue.main.async {
                self.delegate?.satanManager(didUpdateState: .start)
            }
        }
        swiftBleSwitching = {
            //需要添加交换距离接口
            data in
            let doing: protocol_switch_ble_ing = data.assumingMemoryBound(to: protocol_switch_ble_ing.self).pointee
            //传入要交换的的距离，如gps信号不好，则直接把未添加的距离返回去
            DispatchQueue.main.async {
                if let distance = self.delegate?.satanManagerDistanceByLocation(withBleDistance: doing.distance){
                    DispatchQueue.global().async {
                        self.sendSwitchDoing(distance)
                    }
                }
            }
        }
        swiftBleSwitchPause = {
            data in
            //let pause: protocol_switch_ble_pause = data.assumingMemoryBound(to: protocol_switch_ble_pause.self).pointee
            self.sendSwitchPause(0x01)
            //暂停定位
            DispatchQueue.main.async {
                self.delegate?.satanManager(didUpdateState: .pause)
            }
        }
        swiftBleSwitchRestore = {
            data in
            //let restore: protocol_switch_ble_restore = data.assumingMemoryBound(to: protocol_switch_ble_restore.self).pointee
            self.sendSwitchRestore(0x01)
            //继续定位
            DispatchQueue.main.async {
                self.delegate?.satanManager(didUpdateState: .restore)
            }
        }
        swiftBleSwitchEnd = {
            data in
            //let end: protocol_switch_ble_end = data.assumingMemoryBound(to: protocol_switch_ble_end.self).pointee
            self.sendSwitchEnd(0x01)
            
            self.curDate = nil
            //停止定位
            DispatchQueue.main.async {
                self.delegate?.satanManager(didUpdateState: .end)
            }
        }
    }
    
    // MARK:- app发起交换数据--app操作
    //开始交换数据
    public func appSwitchStart(withParam start: SwitchStart, closure: @escaping (_ errorCode: Int16, _ status: SwitchStartStatus?)->()){
        
        //判断连接
        guard isPeripheralConnected() else {
            closure(ErrorCode.failure, nil)
            return
        }

        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: start.date)
        
        var switchStart = protocol_switch_app_start()
        switchStart.start_time.day   = UInt8(components.day!)
        switchStart.start_time.hour = UInt8(components.hour!) 
        switchStart.start_time.minute = UInt8(components.minute!)
        switchStart.start_time.second = UInt8(components.second!)
        switchStart.sport_type = start.sportType                    //运动类型
        switchStart.target_type = start.targetType                  //目标类型
        switchStart.target_value = start.targetValue                //目标值
        switchStart.force_start = start.forceStart ? 0x01 : 0x00    //0x01:强制开始有效， 0x00:强制开始无效
        let length = UInt32(MemoryLayout<UInt8>.size * 9) + UInt32(MemoryLayout<UInt32>.size)
        var  ret_code: UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_STAERT, &switchStart, length, &ret_code)
        guard ret_code == 0 else {
            closure(ErrorCode.failure, nil)
            return
        }
        swiftSwitchStartReply = {
            data in
            
            //判断是否已开始，避免重复创建
            guard self.curDate == nil else{
                return
            }
            
            let startReply: protocol_switch_app_start_reply = data.assumingMemoryBound(to: protocol_switch_app_start_reply.self).pointee
            //0x00:成功; 0x01:设备已经进入运动模式失败;0x02: 设备电量低失败
            guard let status = SwitchStartStatus(rawValue: startReply.ret_code) else{
                closure(ErrorCode.failure, nil)
                return
            }
            //开始定位
            DispatchQueue.main.async {
                if status == .normal {
                    
                    
                    self.delegate?.satanManager(didUpdateState: .start)
                    
                    //创建新路线 存储当前时间
                    let components = self.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: start.date)
                    self.curDate = self.calendar.date(from: components)
                    
                    //自动调用数据交换
                    self.appSwitch(flag: true)
                    
                    closure(ErrorCode.success, status)
                    
                    guard let macaddress = self.angelManager?.macAddress else{
                        return
                    }
                    
                    //插入数据库
                    let userId = UserManager.share().userId
                    guard let track = self.coredataHandler.insertTrack(userId: userId, withMacAddress: macaddress, withDate: self.curDate!, withItems: nil) else{
                        return
                    }
                    track.type = Int16(start.sportType)         //运动类型
                    
                    guard self.coredataHandler.commit() else {
                        return
                    }
                }
            }
        }
    }
    
    //MARK:- 运动中存储坐标数据
    public func addTrack(withCoordinate coordinate: CLLocationCoordinate2D, withInterval interval: TimeInterval, totalDistance distance: Double, childDistance subDistance: Double){
        guard let macaddress = angelManager?.macAddress, let date = curDate else {
            return
        }
        
        let userId = UserManager.share().userId
        _ = coredataHandler.createTrackItem(userId: userId, withMacAddress: macaddress, withDate: date, withTotalDistance: distance, withCoordinate: coordinate, interval: interval, childDistance: subDistance)
    }
    
    //MARK:- 当运动距离过小，从数据库移除该次运动
    public func resetTrack(){
        guard let macaddress = angelManager?.macAddress else {
            return
        }
        guard let date = curDate else {
            return
        }

        curDate = nil
        
        let coredataHandler = CoreDataHandler.share()
        let userId = UserManager.share().userId
        coredataHandler.deleteTrack(userId: userId, withMacAddress: macaddress, withDate: date)
    }
    
    //MARK:- 自动开始与停止交换
    private var task: TimeTask?
    private var bleDistance: UInt32 = 0
    private func appSwitch(flag: Bool){
        if flag {
            //交换数据
            let switchDoing = SwitchDoing()
            if let distance = self.delegate?.satanManagerDistanceByLocation(withBleDistance: bleDistance){
                switchDoing.distance = UInt32(distance)
            }
            if let duration = self.delegate?.satanManagerDuration(){
                switchDoing.duration = UInt32(duration)
            }
            self.appSwitchDoing(withParam: switchDoing){
                errorCode, switchDoingReply in
                guard errorCode == ErrorCode.success else{
                    return
                }
                guard let reply = switchDoingReply else{
                    return
                }
                DispatchQueue.main.async {
                    self.bleDistance = reply.distance
                    self.delegate?.satanManager(didSwitchingReplyCalories: reply.calories,
                                                distance: reply.distance, step: reply.step,
                                                curHeartrate: reply.curHrValue,
                                                heartrateSerial: reply.hrValueSerial,
                                                available: reply.available,
                                                heartrateValue: [reply.hrValue.0, reply.hrValue.1, reply.hrValue.2, reply.hrValue.3, reply.hrValue.4, reply.hrValue.5])
                }
            }
            
            //循环
            if task != nil{
                cancel(task)
            }
            task = delay(2){
                self.appSwitch(flag: flag)
            }
        }else{
            cancel(task)
            task = nil
            bleDistance = 0
        }
    }
    
    //交换数据中 2s一次
    public func appSwitchDoing (withParam doing: SwitchDoing, closure: @escaping (_ errorCode:Int16, _ reply: SwitchDoingReply?)->()){
        
        guard isPeripheralConnected() else {
            closure(ErrorCode.failure, nil)
            return
        }
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: doing.date)
        
        var switchDoing = protocol_switch_app_ing()
        switchDoing.start_time.day   = UInt8(components.day!)
        switchDoing.start_time.hour = UInt8(components.hour!) 
        switchDoing.start_time.minute = UInt8(components.minute!)
        switchDoing.start_time.second = UInt8(components.second!)
        switchDoing.calories = doing.calories
        switchDoing.distance = doing.distance
        switchDoing.duration = doing.duration
        switchDoing.flag = doing.flag               //0x00:全部有效， 0x01:距离无效，0x02:gps信号弱
        let length = UInt32(MemoryLayout<UInt8>.size * 7) + UInt32(MemoryLayout<UInt32>.size * 3)
        var  ret_code: UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_ING, &switchDoing, length, &ret_code)
        guard ret_code == 0 else {
            closure(ErrorCode.failure, nil)
            return
        }
        
        swiftSwitchingReply = {
            data in
            let doingReply: protocol_switch_app_ing_reply = data.assumingMemoryBound(to: protocol_switch_app_ing_reply.self).pointee
            let switchReply: SwitchDoingReply = SwitchDoingReply()
            switchReply.calories = doingReply.calories
            switchReply.distance = doingReply.distance
            switchReply.step = doingReply.step
            switchReply.curHrValue = doingReply.hr_item.cur_hr_value
            switchReply.hrValueSerial = doingReply.hr_item.hr_value_serial                          //.1序列号 每组6个数据
            switchReply.available = doingReply.hr_item.interval_second > 0 ? true : false           //5s返回一组合法心率数据
            switchReply.hrValue = doingReply.hr_item.hr_vlaue                                       //心率数据
            
            DispatchQueue.main.async {
                //返回根据序列号绘制曲线
                closure(ErrorCode.success, switchReply)
            }
            
            //存数据库
            guard let date = self.curDate, let macaddress = self.angelManager?.macAddress else {
                return
            }
            let userId = UserManager.share().userId
            guard let track = self.coredataHandler.selectTrack(userId: userId, withMacAddress: macaddress, withDate: date, withDayRange: 0).last else {
                return
            }
            track.calories = Int16(switchReply.calories)
            track.distance = Double(switchReply.distance)
            track.step = Int16(switchReply.step)
            let serial = Int16(doingReply.hr_item.hr_value_serial)      //序列号 * 6 for heartrateId
            if switchReply.available {
                let tuple = switchReply.hrValue
                //添加心率数据
                _ = self.coredataHandler.createTrackHeartrateItem(userId: userId, withMacAaddress: macaddress, withDate: date, withHeartrateId: serial * 6 + 0, withOffset: 0, withData: Int16(tuple.0))
                _ = self.coredataHandler.createTrackHeartrateItem(userId: userId, withMacAaddress: macaddress, withDate: date, withHeartrateId: serial * 6 + 1, withOffset: 0, withData: Int16(tuple.1))
                _ = self.coredataHandler.createTrackHeartrateItem(userId: userId, withMacAaddress: macaddress, withDate: date, withHeartrateId: serial * 6 + 2, withOffset: 0, withData: Int16(tuple.2))
                _ = self.coredataHandler.createTrackHeartrateItem(userId: userId, withMacAaddress: macaddress, withDate: date, withHeartrateId: serial * 6 + 3, withOffset: 0, withData: Int16(tuple.3))
                _ = self.coredataHandler.createTrackHeartrateItem(userId: userId, withMacAaddress: macaddress, withDate: date, withHeartrateId: serial * 6 + 4, withOffset: 0, withData: Int16(tuple.4))
                _ = self.coredataHandler.createTrackHeartrateItem(userId: userId, withMacAaddress: macaddress, withDate: date, withHeartrateId: serial * 6 + 5, withOffset: 0, withData: Int16(tuple.5))
            }else{
                               
            }
            guard self.coredataHandler.commit() else {
                return
            }
        }
    }
    
    //交换数据暂停
    public func appSwitchingPause(withParam pause: SwitchPauseOrContinue, closure: @escaping (_ errorCode: Int16)->()){
        
        guard isPeripheralConnected() else {
            closure(ErrorCode.failure)
            return
        }
        
        guard let date = curDate else {
            closure(ErrorCode.failure)
            return
        }
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: date)
        
        var switchPause = protocol_switch_app_pause()
        switchPause.start_time.day   = UInt8(components.day!)
        switchPause.start_time.hour = UInt8(components.hour!) 
        switchPause.start_time.minute = UInt8(components.minute!)
        switchPause.start_time.second = UInt8(components.second!)
        let length = UInt32(MemoryLayout<UInt8>.size * 6)
        var  ret_code: UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SWITCH_APP_PAUSE, &switchPause, length, &ret_code)
        
        guard ret_code == 0 else {
            closure(ErrorCode.failure)
            return
        }
        swiftSwitchPauseReply = {
            data in
            let pause: protocol_switch_app_pause_reply = data.assumingMemoryBound(to: protocol_switch_app_pause_reply.self).pointee
            //暂停定位***
            DispatchQueue.main.async {
                closure(Int16(pause.err_code))
                self.delegate?.satanManager(didUpdateState: .pause)
            }
        }
    }
    
    //交换数据继续
    public func appSwitchRestore(withParam restore:SwitchPauseOrContinue, closure: @escaping (_ errorCode: Int16)->()){

        guard isPeripheralConnected() else {
            closure(ErrorCode.failure)
            return
        }
        
        guard let date = curDate else {
            closure(ErrorCode.failure)
            return
        }
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: date)
        
        var switchRestore = protocol_switch_app_restore()
        switchRestore.start_time.day   = UInt8(components.day!)
        switchRestore.start_time.hour = UInt8(components.hour!) 
        switchRestore.start_time.minute = UInt8(components.minute!)
        switchRestore.start_time.second = UInt8(components.second!)
        let length = UInt32(MemoryLayout<UInt8>.size * 6)
        var  ret_code: UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SWITCH_APP_RESTORE, &switchRestore, length, &ret_code)
        
        guard ret_code == 0 else {
            closure(ErrorCode.failure)
            return
        }
        
        swiftSwitchRestoreReply = {
            data in
            let restore: protocol_switch_app_restore_reply = data.assumingMemoryBound(to: protocol_switch_app_restore_reply.self).pointee
            //继续定位***
            DispatchQueue.main.async {
                closure(Int16(restore.err_code))
                self.delegate?.satanManager(didUpdateState: .restore)
            }
        }
    }
    
    //交换数据结束
    public func appSwitchEnd(withParam end: SwitchEnd, closure:@escaping (_ errorCode: Int16 , _ reply: SwitchEndReply?)->()){
        
        guard isPeripheralConnected() else {
            closure(ErrorCode.failure, nil)
            return
        }
        
        guard let date = curDate else {
            closure(ErrorCode.failure, nil)
            return
        }
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: date)
        
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
        var  ret_code: UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_APP_END, &switchEnd, length, &ret_code)
        
        guard ret_code == 0 else {
            closure(ErrorCode.failure, nil)
            return
        }
        
        swiftSwitchEndReply = {
            data in
            let switchEndStruct: protocol_switch_app_end_reply = data.assumingMemoryBound(to: protocol_switch_app_end_reply.self).pointee
            let endReplyResult = SwitchEndReply()
            endReplyResult.endSuccess = switchEndStruct.err_code == 0x01           //结束成功返回 0x01 0x00
            endReplyResult.step = switchEndStruct.step
            endReplyResult.calories = switchEndStruct.calories
            endReplyResult.distance = switchEndStruct.distance
            endReplyResult.avgHrValue = switchEndStruct.hr_value.avg_hr_value
            endReplyResult.maxHrValue = switchEndStruct.hr_value.max_hr_value
            endReplyResult.burnFatMins = switchEndStruct.hr_value.burn_fat_mins
            endReplyResult.aerobicMins = switchEndStruct.hr_value.aerobic_mins
            endReplyResult.limitMins = switchEndStruct.hr_value.limit_mins
            //存数据库
            guard let date = self.curDate, let macaddress = self.angelManager?.macAddress else {
                return
            }
            let userId = UserManager.share().userId
            guard let track = self.coredataHandler.selectTrack(userId: userId, withMacAddress: macaddress, withDate: date, withDayRange: nil).last else {
                return
            }
            track.date = date as NSDate?
            track.step = Int16(endReplyResult.step)
            track.aerobicMinutes = Int16(endReplyResult.aerobicMins)
            track.avgrageHeartrate = Int16(endReplyResult.avgHrValue)
            track.burnFatMinutes = Int16(endReplyResult.burnFatMins)
            track.calories = Int16(endReplyResult.calories)
            track.distance = Double(endReplyResult.distance)
            guard self.coredataHandler.commit() else {
                return
            }
            
            //回调
            DispatchQueue.main.async {                
                closure(ErrorCode.success, endReplyResult)
            }
        }
        
        //结束数据交换
        appSwitch(flag: false)
        
        //结束定位
        DispatchQueue.main.async {
            self.curDate = nil
            self.delegate?.satanManager(didUpdateState: .end)
        }
    }
    
    //同步活动数据
    public func setSynchronizationActiveData(_ macAddress: String? = nil, closure:@escaping (_ complete: Bool, _ progress: Int16 ,_ timeOut:Bool)->()){
        
        guard isPeripheralConnected() else {
            closure(false, 0, false)
            return
        }
        
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = angelManager?.macAddress{
            realMacAddress = md
        }else{
            return
        }
        
        swiftSyncActiveProgress = {
            /*data为同步百分比 */
            data in
            closure(false, Int16(data), false)
        }
        
        swiftSyncActiveComplete = {
            closure(true, 100, false)
        }
        
        swiftSyncActiveTimeOut = {
            closure(false,0,true)
        }
        
        swiftSyncActiveData = {
            data in
            let activeData: protocol_activity_data = data.assumingMemoryBound(to: protocol_activity_data.self).pointee
            
            //存数据库
            let head = activeData.head
            let data1 = activeData.ex_data1
            let data2 = activeData.ex_data2
            let hrValues = activeData.hr_value
            
            let year = Int(head.time.year)
            let month = Int(head.time.month)
            let day = Int(head.time.day)
            let hour = Int(head.time.hour)
            let minute = Int(head.time.minute)
            let second = Int(head.time.second)
            var components = self.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            guard year != 0, month != 0, day != 0 else {
                return
            }
            components.year = year + 2000
            components.month = month
            components.day = day
            components.hour = hour
            components.minute = minute
            components.second = second
            guard let date = self.calendar.date(from: components) else{
                return
            }
            let userId = UserManager.share().userId
            guard let track = self.coredataHandler.insertTrack(userId: userId, withMacAddress: realMacAddress, withDate: date, withItems: nil) else {
                return
            }
            track.aerobicMinutes = Int16(data2.aerobic_mins)
            track.avgrageHeartrate = Int16(data2.avg_hr_value)
            track.burnFatMinutes = Int16(data2.burn_fat_mins)
            track.calories = Int16(data1.calories)
            track.date = date as NSDate?
            track.distance = Double(data1.distance)
            track.durations = Int16(data1.durations)
            //存储心率
            let count: Int = 2 * 60 * 60 / 5
            (0..<count).forEach{
                i in
                if let value = hrValues?[i]{
                    if value != 0{
                        _ = self.coredataHandler.createTrackHeartrateItem(userId: userId, withMacAaddress: realMacAddress, withDate: date, withHeartrateId: Int16(i), withOffset: 0, withData: Int16(value))
                    }
                }
            }
            track.limitMinutes = Int16(data2.limit_mins)
            track.maxHeartrate = Int16(data2.max_hr_value)
            track.serial = Int16(head.serial)
            track.step = Int16(data1.step)
            track.type = Int16(data1.type)
            DispatchQueue.main.async {
                _ = self.coredataHandler.commit()
            }
        }
        
        protocol_sync_activity_start()
    }
    
    //获取同步项个数
    public func getSynchronizationActiveCount(_ macAddress: String? = nil, closure:@escaping (_ count: UInt8) -> ()){
        
        guard isPeripheralConnected() else {
            closure(0)
            return
        }
        
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = angelManager?.macAddress{
            realMacAddress = md
        }else{
            closure(0)
            return
        }
        
        swiftGetActiveCount = {
            data in
            let activeCount: protocol_new_health_activity_count = data.assumingMemoryBound(to: protocol_new_health_activity_count.self).pointee
            closure(activeCount.count)
        }
        
        var ret_code: UInt32 = 0
        vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_ACTIVITY_COUNT, &ret_code)
    }
    //回复手环端发起的请求
    private func sendSwitchStart(_ retCode: Int){
        var ret_code: UInt32 = 0
        var reply: protocol_switch_ble_start_reply = protocol_switch_ble_start_reply()
        reply.ret_code = UInt8(retCode)
        let length = UInt32(MemoryLayout<UInt8>.size * 3)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SWITCH_BLE_START_REPLY, &reply, length, &ret_code)
    }
    
    private func sendSwitchPause(_ retCode:Int){
        var ret_code:UInt32 = 0
        var reply: protocol_switch_ble_pause_reply = protocol_switch_ble_pause_reply()
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        reply.ret_code = UInt8(retCode)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_BLE_PAUSE_REPLY,&reply,length,&ret_code)
        
    }
    private func sendSwitchRestore(_ retCode:Int){
        var ret_code:UInt32 = 0
        var reply: protocol_switch_ble_restore_reply = protocol_switch_ble_restore_reply()
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        reply.ret_code = UInt8(retCode)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SWITCH_BLE_RESTORE_REPLY, &reply, length, &ret_code)
        
    }
    private func sendSwitchEnd(_ retCode:Int){
        var ret_code:UInt32 = 0
        var reply: protocol_switch_ble_end_reply = protocol_switch_ble_end_reply()
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        reply.ret_code = UInt8(retCode);

        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SWITCH_BLE_END_REPLY, &reply, length, &ret_code)
        
    }
    private func sendSwitchDoing(_ distance: UInt32){
        var ret_code:UInt32 = 0
        var reply: protocol_switch_ble_ing_reply = protocol_switch_ble_ing_reply()
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        reply.distance = distance           //总距离                                                                                                                                                                                                                               z
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SWITCH_BLE_ING_REPLY, &reply,length, &ret_code)
        
    }
}
