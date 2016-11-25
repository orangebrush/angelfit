//
//  InterfaceListHander.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/16.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
import CoreBluetooth

public final class AngelManager: NSObject {
    
//    var actionMap:[ActionType:[UInt8]]?{
//        let map:[ActionType:[UInt8]] = [.binding:[0x04, 0x01, 0x01, 0x83, 0x55, 0xaa],
//                                        .unbinding:[0x04, 0x02, 0x55, 0xaa, 0x55, 0xaa],
//                                        .responceType:[0x07, 0xA1, 0x01],
//                                        .activated:[0x02, 0xA1]]
//        return map
//    }
    
    private var peripheral: CBPeripheral?       //当前设备
    private var macAddress: String?             //当前设备macAddress
    
    //MARK:- 获取数据库句柄
    private lazy var coredataHandler = {
        return CoreDataHandler()
    }()
    
    //MARK:- init +++++++++++++++++++
    private static var __once: AngelManager? {
        guard let peripheral = PeripheralManager.share().currentPeripheral else{
            return nil
        }
        return AngelManager(currentPeripheral: peripheral)
    }
    public class func share() -> AngelManager?{
        return __once
    }
    
    convenience init(currentPeripheral existPeripheral: CBPeripheral) {
        self.init()
        
        peripheral = existPeripheral
    }
    
    override init(){
        super.init()
        
        //初始化获取macAddress
        getMacAddressFromBand(){
            errorCode, data in
            if errorCode == ErrorCode.success{
                self.macAddress = data
            }
        }
    }
    
    //MARK:- 从数据库获取数据-用户信息
    public func getUserinfo(userId id: Int16 = 1, closure: (User?)->()){
        
        closure(coredataHandler.selectUser(userId: id))
    }
    
    //MARK:- 从数据库获取数据-设备信息
    public func getDevice(_ macAddress: String? = nil, userId id: Int16 = 1, closure: @escaping (Device?) -> ()){
        //为空直接返回失败
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
        guard let device = coredataHandler.selectDevice(userId: id, withMacAddress: realMacAddress) else {
            getDeviceInfoFromBand(){
                errorCode, value in
                if errorCode == ErrorCode.success{
                    closure(self.coredataHandler.selectDevice(userId: id, withMacAddress: realMacAddress))
                }else{
                    closure(nil)
                }
            }
            return
        }
        closure(device)
    }
    
    //获取设备信息
    private func getDeviceInfoFromBand(closure : @escaping (_ errorCode:Int16 ,_ value: String)->()){
        getLiveDataFromBring(withActionType: .deviceInfo, closure: closure)
    }
    
    //获取mac地址
    public func getMacAddressFromBand( closure: @escaping (_ errorCode:Int16 ,_ value: String)->()){
        getLiveDataFromBring(withActionType: .macAddress, closure: closure)
    }
    
    //获取功能列表
    private func getFuncTableFromBand(_ macAddress: String? = nil, closure : @escaping (_ errorCode:Int16 ,_ value: String)->()){
        getLiveDataFromBring(withActionType: .funcTable, macAddress: macAddress, closure: closure)
    }
    
    //从数据库获取功能列表
    public func getFuncTable(_ macAddress: String? = nil, userId id: Int16 = 1, closure: @escaping (FuncTable?) -> ()){
        //为空直接返回失败
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
//        guard let funcTable = coredataHandler.selectDevice(userId: id, withMacAddress: realMacAddress)?.funcTable else{
            getFuncTableFromBand(realMacAddress){
                errorCode, value in
                debug("funcTable errorCode: \(errorCode) value: \(value)")
                if errorCode == ErrorCode.success{
                    closure(self.coredataHandler.selectDevice(userId: id, withMacAddress: realMacAddress)?.funcTable)
                }else{
                    closure(nil)
                }
            }
            return
//        }
        
//        closure(funcTable)
    }
    
    //获取实时数据
    public func getLiveDataFromBand(closure : @escaping (_ errorCode:Int16 ,_ value: String)->()){
        getLiveDataFromBring(withActionType: .liveData, closure: closure)
    }
    
    //MARK:- 从手环端获取数据
    private func getLiveDataFromBring(withActionType actionType:ActionType, macAddress: String? = nil, closure: @escaping (_ errorCode:Int16 ,_ value: String) ->()){
        
        switch actionType {
        case .macAddress:
            
            swiftMacAddress = { data  in
                
                let macStruct:protocol_device_mac = data.assumingMemoryBound(to: protocol_device_mac.self).pointee
                let macCList = macStruct.mac_addr
                let macList = [macCList.0, macCList.1, macCList.2, macCList.3, macCList.4, macCList.5]
                let macAddress = macList.map(){String($0,radix:16)}.reduce(""){$0+$1}.uppercased()
                
                //保存macAddress到数据库
                _ = self.coredataHandler.insertDevice(withMacAddress: macAddress)
                //保存macAddress到实例
                self.macAddress = macAddress
                //返回
                closure(ErrorCode.success,macAddress)
            }
            var ret_code:UInt32 = 0
            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_APP_GET_MAC, &ret_code);

        case .deviceInfo:
            swiftDeviceInfo = { data in
                
                let deviceInfo = data.assumingMemoryBound(to: protocol_device_info.self).pointee
                
                //保存数据库
                var realMacAddress: String!
                if let md = macAddress{
                    realMacAddress = md
                }else if let md = self.macAddress{
                    realMacAddress = md
                }else{
                    closure(ErrorCode.failure, "macaddress is empty")
                    return
                }
                
                let device = self.coredataHandler.selectDevice(withMacAddress: realMacAddress)
                device?.bandStatus = Int16(deviceInfo.batt_status)
                device?.battLevel = Int16(deviceInfo.batt_level)
                device?.version = Int16(deviceInfo.version)
                device?.pairFlag = deviceInfo.pair_flag == 0x01 ? true : false
                device?.rebootFlag = deviceInfo.reboot_flag == 0x01 ? true : false
                device?.mode = Int16(deviceInfo.mode)
                device?.deviceId = Int16(deviceInfo.device_id)
                if deviceInfo.reboot_flag == 0x01 {
                    //如果有重启标志==1,同步设备信息
                    self.setSynchronizationConfig(){
                        complete in
                    }
                }
                
                
                guard self.coredataHandler.commit() else{
                    closure(ErrorCode.failure, "commit fail")
                    return
                }
                
                closure(ErrorCode.success, "\(deviceInfo)")
            }
            
            var ret_code:UInt32 = 0
            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_DEVICE_INFO, &ret_code)
            
        case .funcTable:
            
            //为空直接返回失败
            var realMacAddress: String!
            if let md = macAddress{
                realMacAddress = md
            }else if let md = self.macAddress{
                realMacAddress = md
            }else{
                closure(ErrorCode.failure, "macAddress is empty")
                break
            }
            
            swiftFuncTable = { data in
                
                debug("--------------\n已经获取funcTable")
                
                let funcTableModel = data.assumingMemoryBound(to: protocol_func_table.self).pointee
                print("--------------\nprint:funcTable\n\(funcTableModel)")
                let funcTable = self.coredataHandler.selectDevice(withMacAddress: realMacAddress)?.funcTable
                
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
                
                debug("coreData functable: \(funcTable)")
                guard self.coredataHandler.commit() else {
                    closure(ErrorCode.failure, "saving failure")
                    return
                }
                closure(ErrorCode.success, "\(funcTable)")
            }
            debug("--------------\n开始获取funcTable")
            var ret_code:UInt32 = 0

            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_FUNC_TABLE, &ret_code)
            print("获取功能列表 \(ret_code)")
        case .liveData:
            //实时数据
            swiftLiveData = { data in
                
                let liveDataStruct:protocol_start_live_data = data.assumingMemoryBound(to: protocol_start_live_data.self).pointee
                
                let liveData = liveDataStruct
                
                closure(ErrorCode.success, "\(liveData)")
            }
            var ret_code:UInt32 = 0
            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_LIVE_DATA, &ret_code)
     
        }
    }
    
    //MARK:- 设置手环端命令
    //设置手环模式
    private func setBringMode(_ bandMode:BandMode, completed: Bool = true, closure: @escaping (_ success:Bool) ->()){
        
        guard completed else {
            closure(false)
            return
        }
        
        var ret_code:UInt32 = 0
        switch bandMode {
        case .unbind:
            closure(protocol_set_mode(PROTOCOL_MODE_UNBIND) == 0)
            //解绑当前设备uuid
            let uuid = PeripheralManager.share().UUID
            _ = PeripheralManager.share().delete(UUIDString: uuid!)
        case .bind:
            closure(protocol_set_mode(PROTOCOL_MODE_BIND) == 0)
            //保存绑定当前设备uuid
            let uuid = PeripheralManager.share().UUID
            _ = PeripheralManager.share().add(newUUIDString: uuid!)
        case .levelup:
            vbus_tx_evt(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_OTA_START, &ret_code)
            
            if ret_code == 0 {
                protocol_set_mode(PROTOCOL_MODE_OTA)
                closure(true)
                
            }else{
                closure(false)
            }
        }
    }
    
    //MARK:- 升级
    public func setUpdate(closure: @escaping (_ success: Bool) -> ()){
        setBringMode(.levelup, closure: closure)
    }
    
    //MARK:- 绑定
    public func setBind(_ bind: Bool, closure: @escaping (_ success: Bool) -> ()){
        var ret_code:UInt32 = 0
        var evt_type:VBUS_EVT_TYPE
    
        if bind{
            evt_type = VBUS_EVT_APP_BIND_START
        } else {
            evt_type = VBUS_EVT_APP_BIND_REMOVE
        }
        vbus_tx_evt(VBUS_EVT_BASE_APP_SET, evt_type, &ret_code);
        
        let bandMode = bind ? BandMode.bind : BandMode.unbind
        if ret_code == 0 {
            setBringMode(bandMode, completed: true, closure: closure)
        }else{
            setBringMode(bandMode, completed: false, closure: closure)
        }
    }
    
    //MARK:- 设置手环日期
    public func setDate(date: Date = Date(), closure:(_ success:Bool) ->()){
        
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: date)
        var time = protocol_set_time()
        time.year = UInt16(components.year!)
        time.month =  UInt8(components.month!)
        time.day = UInt8(components.day!)
        time.hour = UInt8(components.hour!)
        time.minute = UInt8(components.minute!)
        time.second = UInt8(components.second!)
        time.week = UInt8(components.weekday!)
        
        let length = UInt32(MemoryLayout<UInt16>.size+MemoryLayout<UInt8>.size * 8)
        
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_TIME, &time, length, &ret_code);
        closure(ret_code == 0)
    }
    
    //MARK:- 设置用户信息
    public func setUserInfo(_ userInfo:UserInfoModel, closure:(_ success:Bool) ->()){
        
        var userInfoModel = protocol_set_user_info()
        userInfoModel.heigth = userInfo.height
        userInfoModel.weight = userInfo.weight * 100
        userInfoModel.gender = userInfo.gender
        userInfoModel.year = userInfo.birthYear
        userInfoModel.monute = userInfo.birthMonth
        userInfoModel.day = userInfo.birthDay
        
        var ret_code:UInt32 = 0
        let length = UInt32(MemoryLayout<UInt16>.size+MemoryLayout<UInt8>.size*7)
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_USER_INFO, &userInfoModel, length, &ret_code)
        
        guard ret_code==0 else {
            closure(false)
            return
        }
        //保存到数据库
        let user = coredataHandler.selectUser()
        let calender = Calendar.current
        var components = calender.dateComponents([.year, .month, .day], from: Date())
        components.year = Int(userInfo.birthYear)
        components.month = Int(userInfo.birthMonth)
        components.day = Int(userInfo.birthDay)
        let birthDay = calender.date(from: components)
        user?.birthday = birthDay as NSDate?
        user?.gender = Int16(userInfo.gender)
        user?.height = Int16(userInfo.height)
        user?.weight = Int16(userInfo.weight)
        guard coredataHandler.commit() else{
            closure(false)
            return
        }
        
        closure(true)
    }
    
    //MARK:- 设置久坐提醒
    public func setLongSit(_ sit:LongSitModel, macAddress: String? = nil, closure:(_ success:Bool) ->()){
        
        var long_sit = protocol_long_sit()
        
        long_sit.start_hour = sit.startHour
        long_sit.start_minute = sit.startMinute
        long_sit.end_hour = sit.endHour
        long_sit.end_minute = sit.endMinute
        long_sit.interval = sit.duringTime
        
        //0,1,2,3,4,5,6 日。。。六
        var val = sit.weekdayList.reduce(0){$0 | ($1 == 0 ? 0x1 : (($1 < 7 && $1 > 0) ? 0x01 << UInt8(7 - $1) : 0x00))}
        val = val | (sit.isOpen ? 0x01 << 7 : 0x00)
        long_sit.repetitions = val
        
        var ret_code:UInt32 = 0
        
        let length = UInt32(MemoryLayout<UInt16>.size + MemoryLayout<UInt8>.size * 7)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_LONG_SIT, &long_sit, length, &ret_code)
        guard ret_code == 0 else{
            closure(false)
            return
        }
        
        //保存数据库
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        let dbLongsit = coredataHandler.selectLongSit(withMacAddress: realMacAddress)
        let calender = Calendar.current
        var components = calender.dateComponents([.hour, .minute], from: Date())
        components.hour = Int(sit.startHour)
        components.minute = Int(sit.startMinute)
        let startDate = calender.date(from: components)
        dbLongsit?.startDate = startDate as NSDate?
        
        components.hour = Int(sit.endHour)
        components.minute = Int(sit.endMinute)
        let endDate = calender.date(from: components)
        dbLongsit?.endDate = endDate as NSDate?
        
        dbLongsit?.interval = Int16(sit.duringTime)
        dbLongsit?.isOpen = sit.isOpen
        
        dbLongsit?.weekdayList = sit.weekdayList as NSObject?
        
        closure(true)
    }
    
    //MARK:- 设置公英制
    public func setUnit(_ unitsType: Set<UnitType>, macAddress: String? = nil, closure:(_ success:Bool) ->()){
        
        //为空直接返回失败
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        guard !unitsType.isEmpty else {
            closure(false)
            return
        }
        
        //默认赋值
        var setUnit = protocol_set_uint()
        if setUnit.dist_uint == 0x00{
            setUnit.dist_uint = 0x01
        }
        if setUnit.is_12hour_format == 0x00{
            setUnit.is_12hour_format = 0x01
        }
        if setUnit.language == 0x00{
            setUnit.language = 0x01
        }
        if setUnit.stride == 0{
            setUnit.stride = 70
        }
        if setUnit.temp == 0x00{
            setUnit.temp = 0x01
        }
        if setUnit.weight_uint == 0x00{
            setUnit.weight_uint = 0x01
        }
        
        //创建单位模型
        let unit = coredataHandler.selectUnit(withMacAddress: realMacAddress)
        
        //赋值
        unitsType.forEach(){
            body in
            
            switch body{
            case .distance_KM:
                setUnit.dist_uint = 0x01
                unit?.distance = 0x01
            case .distance_MI:
                setUnit.dist_uint = 0x02
                unit?.distance = 0x02
            case  .langure_EN:
                setUnit.language = 0x02
                unit?.language = 0x02
            case .langure_ZH:
                setUnit.language = 0x01
                unit?.language = 0x01
            case .temp_C:
                setUnit.temp = 0x01
                unit?.temperature = 0x01
            case .temp_F:
                setUnit.temp = 0x02
                unit?.temperature = 0x02
            case .timeFormat_12:
                setUnit.is_12hour_format = 0x02
                unit?.timeFormat = 0x02
            case .timeFormat_24:
                setUnit.is_12hour_format = 0x01
                unit?.timeFormat = 0x01
            case .weight_LB:
                setUnit.weight_uint = 0x02
                unit?.weight = 0x02
            case .weight_KG:
                setUnit.weight_uint = 0x01
                unit?.weight = 0x01
            }
        }
        
        /*
         stride 为步长，根据身高和男女运算，详情见协议 70是默认的
         */
        guard let user = coredataHandler.selectUser() else{
            closure(false)
            return
        }
        let height = user.height
        let gender = user.gender
        if gender == 1{
            setUnit.stride = UInt8(Double(height) * 0.415)
        }else{
            setUnit.stride = UInt8(Double(height) * 0.413)
        }
        
        let length = UInt32(MemoryLayout<UInt8>.size * 8)
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_UINT, &setUnit, length, &ret_code)

        guard ret_code == 0 else{
            //重置数据库修改
            _ = coredataHandler.reset()
            closure(false)
            return
        }
        
        //保存数据库
        guard coredataHandler.commit() else{
            closure(false)
            return
        }
        
        closure(true)
    }
    
    //MARK:- 获取公英制
    public func getUnit(_ macAddress: String? = nil, closure: (Unit?)->()){
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        closure(coredataHandler.selectUnit(withMacAddress: realMacAddress))
    }
    
    //设置目标
    public func setGoal(_ goal:GoalDataModel , closure: @escaping (_ success:Bool) ->()){
        
        var ret_code:UInt32 = 0
        var setGoal = protocol_set_sport_goal()
        
        setGoal.type = goal.type
        setGoal.data = goal.value
        setGoal.sleep_hour = goal.sleepHour
        setGoal.sleep_minute = goal.sleepMinute
        
        let length:UInt32 = UInt32(MemoryLayout<UInt32>.size+MemoryLayout<UInt8>.size * 5)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_SPORT_GOAL, &setGoal, length,&ret_code)
        
        guard ret_code == 0 else {
            closure(false)
            return
        }

        //保存数据库
        let user = coredataHandler.selectUser()
        if goal.type == 0x00 {
            user?.goalStep = Int16(goal.value)
        }else if goal.type == 0x01{
            user?.goalCal = Int16(goal.value)
        }else if goal.type == 0x02{
            user?.goalDistance = Int16(goal.value)
        }
        guard coredataHandler.commit() else{
            closure(false)
            return
        }
        
        closure(true)
    }
    
    //MARK:- 设置拍照开关
    public func setCamera(_ open:Bool, closure: @escaping (_ success:Bool) ->()){
        swiftGetCameraSignal = { data in
            closure(true)
        }
        
        var ret_code:UInt32 = 0
        var evt_type:VBUS_EVT_TYPE = VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP
        
        if open == true {
            evt_type = VBUS_EVT_APP_APP_TO_BLE_PHOTO_START
        }else{
            evt_type = VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP
        }
        vbus_tx_evt(VBUS_EVT_BASE_APP_SET, evt_type, &ret_code);
        
        guard ret_code == 0 else {
            closure(false)
            return
        }
    }
    
    //MARK:- 设置寻找手机 timeOut 超时时间
    public func setFindPhone(_ open:Bool, timeOut: UInt8 = 5, macAddress: String? = nil, closure: (_ success:Bool) ->()){
        
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var ret_code:UInt32 = 0
        var findPhone = protocol_find_phone()
        findPhone.status = open ? 0xAA : 0x55
        findPhone.timeout = timeOut
        
        let length = UInt32(MemoryLayout<UInt8>.size * 4)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_FIND_PHONE, &findPhone,length, &ret_code);
        
        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        let device = coredataHandler.selectDevice(withMacAddress: realMacAddress)
        device?.findPhoneSwitch = open
        guard coredataHandler.commit() else{
            closure(false)
            return
        }
        
        closure(true)
    }
    
    //MARK:- 获取是否开启寻找手机
    public func getFindPhone(_ macAddress: String? = nil, closure: (_ open: Bool?)->()){
        
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
        guard let device = coredataHandler.selectDevice(withMacAddress: realMacAddress) else{
            closure(nil)
            return
        }
        closure(device.findPhoneSwitch)
    }
    
    //MARK:- 设置一键还原
    public func setGhost(closure: (_ success:Bool)->()){
        
        var ret_code:UInt32 = 0
        vbus_tx_evt(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_DEFAULT_CONFIG, &ret_code)
        
        guard ret_code == 0 else {
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 设置一键呼叫
    public func setQuickSOS(_ open:Bool, macAddress: String? = nil, closure:(_ success:Bool) ->()){
        
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var ret_code:UInt32 = 0
        var oneKey = protocol_set_onekey_sos()
        
        oneKey.on_off = open ? 0xAA : 0x55
        
        let length = UInt32(MemoryLayout<UInt8>.size*3)
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_ONEKEY_SOS, &oneKey, length, &ret_code)
        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        let device = coredataHandler.selectDevice(withMacAddress: realMacAddress)
        device?.sos = open
        guard coredataHandler.commit() else{
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 获取是否开启一键呼叫
    public func getQuickSOSSwitch(_ macAddress: String? = nil, closure: (_ open: Bool?)->()){
        
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
        guard let device = coredataHandler.selectDevice(withMacAddress: realMacAddress) else{
            closure(nil)
            return
        }
        closure(device.sos)
    }
    
    //重启设备
    public func setRestart(closure:(_ success:Bool) ->()){
        
        var ret_code:UInt32 = 0
        
        vbus_tx_evt(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_REBOOT,&ret_code)
        
        guard ret_code == 0 else {
            closure(false)
            return
        }
        closure(false)
    }
    
    //MARK:- 设置抬腕识别
    public func setWristRecognition(_ open:Bool, lightDuring: UInt8 = 3, closure: (_ success:Bool)->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var wrist = protocol_set_up_hand_gesture()
        var showDuring = lightDuring
        if showDuring < 2{
            showDuring = 2
        }else if showDuring > 7{
            showDuring = 7
        }
        wrist.show_second = showDuring
        wrist.on_off = open ? 0xAA : 0x55
        
        let length = UInt32(MemoryLayout<UInt8>.size * 4)

        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_UP_HAND_GESTURE, &wrist, length, &ret_code);

        guard ret_code == 0 else {
            closure(false)
            return
        }
        
        //保存数据库
        let handGresture = coredataHandler.selectHandGesture(withMacAddress: realMacAddress)
        handGresture?.isOpen = open
        handGresture?.displayTime = Int16(lightDuring)
        guard coredataHandler.commit() else{
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 获取抬腕识别
    public func getWristRecognition(_ macAddress: String? = nil, closure: (HandGesture?)->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
        closure(coredataHandler.selectHandGesture(withMacAddress: realMacAddress))
    }
    
    //设置勿扰模式
    public func setSilent(_ silentModel:SilentModel, macAddress: String? = nil, closure:(_ success:Bool)->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var disturb = protocol_do_not_disturb()
        disturb.switch_flag = silentModel.isOpen ? 0xAA :0x55
        disturb.start_hour = silentModel.startHour
        disturb.start_minute = silentModel.startMinute
        disturb.end_hour = silentModel.endHour
        disturb.end_minute = silentModel.endMinute
        
        let length = UInt32(MemoryLayout<UInt8>.size*7)
        
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_DO_NOT_DISTURB,&disturb,length,&ret_code);

        guard ret_code == 0 else {
            closure(false)
            return
        }
        
        //保存数据库
        let silent = coredataHandler.selectSilentDistrube(withMacAddress: realMacAddress)
        silent?.startHour = Int16(silentModel.startHour)
        silent?.startMinute = Int16(silentModel.startMinute)
        silent?.endHour = Int16(silentModel.endHour)
        silent?.endMinute = Int16(silentModel.endMinute)
        silent?.isOpen = silentModel.isOpen
        guard coredataHandler.commit() else {
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 设置心率区间
    public func setHeartRateInterval(_ heartIntervalModel:HeartIntervalModel ,closure:(_ success:Bool) -> ()){
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var interval = protocol_heart_rate_interval()
        interval.aerobic_threshold = heartIntervalModel.aerobic
        interval.burn_fat_threshold = heartIntervalModel.burnFat
        interval.limit_threshold = heartIntervalModel.limit
        
        
        let length = UInt32(MemoryLayout<UInt8>.size * 5)
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_HEART_RATE_INTERVAL,&interval,length,&ret_code);

        guard ret_code == 0 else {
            closure(false)
            return
        }
        
        //保存数据库
        guard let heartInterval = coredataHandler.selectHeartInterval(withMacAddress: realMacAddress) else {
            closure(false)
            return
        }
        heartInterval.aerobic = Int16(heartIntervalModel.aerobic)
        heartInterval.burnFat = Int16(heartIntervalModel.burnFat)
        heartInterval.limit = Int16(heartIntervalModel.limit)
        guard coredataHandler.commit() else {
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 获取心率区间
    public func getHeartRateInterval(_ macAddress: String? = nil, closure: (HeartInterval?)->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
        closure(coredataHandler.selectHeartInterval(withMacAddress: realMacAddress))
    }
    
    //MARK:- 设置左右手穿戴
    /*handtype true为左手*/
    public func setHand(_ leftHand:Bool , closure:(_ success:Bool)->()){

        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var handle = protocol_set_handle()
        handle.hand_type = leftHand ? 0x00 : 0x01
        
        let length = UInt32(MemoryLayout<UInt8>.size*3)
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_HAND,&handle,length,&ret_code)
        
        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        guard let handGesture = coredataHandler.selectHandGesture(withMacAddress: realMacAddress) else {
            closure(false)
            return
        }
        handGesture.leftHand = leftHand
        guard coredataHandler.commit() else {
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 获取左右手穿戴
    public func getHand(_ macAddress: String? = nil, closure: (_ isLeftHand: Bool?)->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
        guard let handGesture = coredataHandler.selectHandGesture(withMacAddress: realMacAddress) else {
            closure(nil)
            return
        }
        
        closure(handGesture.leftHand)
    }
    
    //MARK:- 设置心率模式
    public func setHeartRateMode(_ heartRateMode: HeartRateMode, macAddress: String? = nil, closure:(_ success:Bool) ->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var mode = protocol_heart_rate_mode()

        switch heartRateMode {
        case .auto:
            mode.mode = 0x88
        case .close:
            mode.mode = 0x55
        case .manual:
            mode.mode = 0xAA
        }
        
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_HEART_RATE_MODE,&mode,length,&ret_code);

        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        guard let heartInterval = coredataHandler.selectHeartInterval(withMacAddress: realMacAddress) else {
            closure(false)
            return
        }
        heartInterval.heartRateMode = Int16(mode.mode)
        guard coredataHandler.commit() else {
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 获取心率模式
    public func getHeartRateMode(_ macAddress: String? = nil, closure: (HeartRateMode?)->()){
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
        guard let heartInterval = coredataHandler.selectHeartInterval(withMacAddress: realMacAddress) else {
            closure(nil)
            return
        }
        let result = heartInterval.heartRateMode
        switch result {
        case 0x88:
            closure(HeartRateMode.auto)
        case 0x55:
            closure(HeartRateMode.close)
        case 0xAA:
            closure(HeartRateMode.manual)
        default:
            closure(nil)
        }
    }
    
    //MARK:- 设置横屏
    public func setLandscape(_ flag: Bool, macAddress: String? = nil, closure:(_ success:Bool) ->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var mode:protocol_display_mode = protocol_display_mode.init()
        
        mode.mode = flag ? 0x01 : 0x02

        let length = UInt32(MemoryLayout<UInt8>.size*3)
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_DISPLAY_MODE,&mode,length,&ret_code);
 
        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        guard let device = coredataHandler.selectDevice(withMacAddress: realMacAddress) else {
            closure(false)
            return
        }
        device.landscape = flag
        guard coredataHandler.commit() else {
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 获取横屏消息
    public func getLangscape(_ macAddress: String? = nil, closure: (_ isLangScape: Bool?)->()){
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
        guard let device = coredataHandler.selectDevice(withMacAddress: realMacAddress) else {
            closure(nil)
            return
        }
        
        closure(device.landscape)
    }
    
    //MARK:- 同步健康数据
    /*
     *  status 是否同步完成
     *  percent 同步百分比
     */
    public func setSynchronizationHealthData(_ macAddress: String? = nil, closure:@escaping (_ complete: Bool, _ progress: Int16) -> ()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false, 0)
            return
        }
        
        //同步进度回调
        swiftSynchronizationHealthData = { data in
            closure(data.0,Int16(data.1))
        }
        
        //获取到运动数据回调
        swiftReadSportData = { data in
            let sportData = data.assumingMemoryBound(to: protocol_health_resolve_sport_data_s.self).pointee
            
            //处理sportData
            let year = sportData.head1.date.year
            let month = sportData.head1.date.month
            let day = sportData.head1.date.day
            var component = DateComponents()
            component.day = Int(day)
            component.month = Int(month)
            component.year = Int(year)
            let optionDate = Calendar.current.date(from: component)       //日期
            let id = 0
            let itemCount = sportData.items_count
            let minuteDuration = sportData.head1.per_minute
            let minuteOffset = sportData.head1.minute_offset
            let totalActiveTime = sportData.head2.total_active_time
            let totalCal = sportData.head2.total_cal
            let totalDistance = sportData.head2.total_distances
            let totalStep = sportData.head2.total_step
            let perMinute = sportData.head1.per_minute
            let packetCount = sportData.head1.packet_count
            
            guard let date = optionDate  else {
                return
            }
            
            guard let sport = self.coredataHandler.insertSportData(withMacAddress: realMacAddress) else {
                return
            }
            sport.date = date as NSDate
            sport.id = Int16(id)
            sport.itemCount = Int16(itemCount)
            sport.minuteDuration = Int16(minuteDuration)
            sport.minuteOffset = Int16(minuteOffset)
            sport.totalActiveTime = Int16(totalActiveTime)
            sport.totalCal = Int16(totalCal)
            sport.totalDistance = Int16(totalDistance)
            sport.perMinute = Int16(perMinute)
            sport.packetCount = Int16(packetCount)
            sport.totalStep = Int16(totalStep)
            guard self.coredataHandler.commit() else {
                return
            }

            let items = sportData.items
            let length = MemoryLayout<ble_sync_sport_item>.size
            (0..<96).forEach(){
                i in
                if let item = items?[length * i]{
                    if let sportItem = self.coredataHandler.createSportItem(withMacAddress: realMacAddress, withDate: date, withItemId: Int16(i)){
                        sportItem.activeTime = Int16(item.active_time)
                        sportItem.calories = Int16(item.calories)
                        sportItem.distance = Int16(item.distance)
                        sportItem.id = Int16(i)
                        sportItem.mode = Int16(item.mode)
                        sportItem.sportCount = Int16(item.sport_count)
                        _ = self.coredataHandler.commit()
                    }
                }
            }
        }
        
        //获取睡眠数据回调
        swiftReadSleepData = { data in
            let sleepData = data.assumingMemoryBound(to: protocol_health_resolve_sleep_data_s.self).pointee
            
            //处理sportData
            let year = sleepData.head1.date.year
            let month = sleepData.head1.date.month
            let day = sleepData.head1.date.day
            var component = DateComponents()
            component.day = Int(day)
            component.month = Int(month)
            component.year = Int(year)
            let optionDate = Calendar.current.date(from: component)       //日期
            let id = 0
            let itemCount = sleepData.itmes_count
            let deepSleepCount = sleepData.head2.deep_sleep_count
            let deepSleepMinute = sleepData.head2.deep_sleep_minute
            let endTimeHour = Int16(sleepData.head1.end_time_hour)
            let endTimeMinute = Int16(sleepData.head1.end_time_minute)
            let lightSleepCount = sleepData.head2.light_sleep_count
            let lightSleepMinute = sleepData.head2.ligth_sleep_minute
            let totalMinute = sleepData.head2.deep_sleep_minute
            let packetCount = sleepData.head1.packet_count
            let sleepItemCount = sleepData.head1.sleep_item_count
            let wakeCount = sleepData.head2.wake_count
            var deltaHour = Int16(totalMinute / 60)
            var deltaMinute = Int16(totalMinute % 60)
            if deltaMinute > endTimeMinute{
                deltaHour += 1
                deltaMinute -= 60
            }
            var startTimeHour = endTimeHour - deltaHour
            while startTimeHour < 0 {
                startTimeHour += 24
            }
            let startTimeMinute = endTimeMinute - deltaMinute
            
            guard let date = optionDate  else {
                return
            }
            
            guard let sleep = self.coredataHandler.insertSleepData(withMacAddress: realMacAddress) else {
                return
            }
            sleep.date = date as NSDate
            sleep.id = Int16(id)

            sleep.itemsCount = Int16(itemCount)
            sleep.packetCount = Int16(packetCount)
            sleep.deepSleepCount = Int16(deepSleepCount)
            sleep.deepSleepMinute = Int16(deepSleepMinute)
            sleep.endTimeHour = Int16(endTimeHour)
            sleep.endTimeMinute = Int16(endTimeMinute)
            sleep.id = Int16(id)
            sleep.lightSleepCount = Int16(lightSleepCount)
            sleep.lightSleepMinute = Int16(lightSleepMinute)
            sleep.sleepItemCount = Int16(sleepItemCount)
            sleep.totalMinute = Int16(totalMinute)
            sleep.wakeCount = Int16(wakeCount)
            sleep.startTimeHour = startTimeHour
            sleep.startTimeMinute = startTimeMinute
            guard self.coredataHandler.commit() else {
                return
            }
            
            let items = sleepData.itmes
            let length = MemoryLayout<ble_sync_sleep_item>.size
            (0..<96).forEach(){
                i in
                if let item = items?[length * i]{
                    if let sleepItem = self.coredataHandler.createSleepItem(withMacAddress: realMacAddress, withDate: date, withItemId: Int16(i)){
                        sleepItem.durations = Int16(item.durations)
                        sleepItem.id = Int16(i)
                        sleepItem.sleepStatus = Int16(item.sleep_status)
                        _ = self.coredataHandler.commit()
                    }
                }
            }
        }
        
        //获取心率数据回调
        swiftReadHeartRateData = { data in
            let heartRateData = data.assumingMemoryBound(to: protocol_health_resolve_heart_rate_data_s.self).pointee
            
            //处理数据
            let year = heartRateData.head1.year
            let month = heartRateData.head1.month
            let day = heartRateData.head1.day
            var component = DateComponents()
            component.day = Int(day)
            component.month = Int(month)
            component.year = Int(year)
            let optionDate = Calendar.current.date(from: component)       //日期
            let id = 0
            let itemCount = heartRateData.items_count
            let aerobicMinutes = heartRateData.head2.aerobic_mins
            let aerobicThreshld = heartRateData.head2.aerobic_threshold
            let burnFatMinutes = heartRateData.head2.burn_fat_mins
            let burnFatThreshold = heartRateData.head2.burn_fat_threshold
            let limitMinutes = heartRateData.head2.limit_mins
            let limitThreshold = heartRateData.head2.limit_threshold
            let minuteOffset = heartRateData.head1.minute_offset
            let packetsCount = heartRateData.head1.packets_count
            let silentHeartRate = heartRateData.head1.silent_heart_rate
            
            guard let date = optionDate  else {
                return
            }
            
            guard let heartRate = self.coredataHandler.insertHeartRateData(withMacAddress: realMacAddress) else {
                return
            }
            heartRate.date = date as NSDate
            heartRate.id = Int16(id)
            heartRate.itemCount = Int16(itemCount)
            heartRate.aerobicMinutes = Int16(aerobicMinutes)
            heartRate.aerobicThreshold = Int16(aerobicThreshld)
            heartRate.burnFatMinutes = Int16(burnFatMinutes)
            heartRate.burnFatThreshold = Int16(burnFatThreshold)
            heartRate.limitMinutes = Int16(limitMinutes)
            heartRate.limitThreshold = Int16(limitThreshold)
            heartRate.minuteOffset = Int16(minuteOffset)
            heartRate.packetsCount = Int16(packetsCount)
            heartRate.silentHeartRate = Int16(silentHeartRate)
         
            guard self.coredataHandler.commit() else {
                return
            }
            
            let items = heartRateData.items
            let length = MemoryLayout<ble_sync_heart_rate_item>.size
            (0..<96).forEach(){
                i in
                if let item = items?[length * i]{
                    if let heartRateItem = self.coredataHandler.createHeartRateItem(withMacAddress: realMacAddress, withDate: date, withItemId: Int16(i)){
                        heartRateItem.data = Int16(item.data)
                        heartRateItem.id = Int16(i)
                        heartRateItem.offset = Int16(item.offset)
                        _ = self.coredataHandler.commit()
                    }
                }
            }
        }
        
        protocol_health_sync_start();
    }
    
    //MARK:- 获取健康数据
    public func getSportData(_ macAddress: String? = nil, userId id: Int16? = 1, date: Date = Date(), offset: Int = 0, closure:(_ result: [SportData]) ->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure([])
            return
        }
        
        closure(coredataHandler.selectSportData(userId: (id ?? 1), withMacAddress: realMacAddress, withDate: date, withDayRange: offset))
    }
    public func getSleepData(_ macAddress: String? = nil, userId id: Int16? = 1, date: Date = Date(), offset: Int = 0, closure:(_ result: [SleepData]) ->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure([])
            return
        }
        
        closure(coredataHandler.selectSleepData(userId: (id ?? 1), withMacAddress: realMacAddress, withDate: date, withDayRange: offset))
    }
    public func getHeartRateData(_ macAddress: String? = nil, userId id: Int16? = 1, date: Date = Date(), offset: Int = 0, closure:(_ result: [HeartRateData]) ->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure([])
            return
        }
        
        closure(coredataHandler.selectHeartRateData(userId: (id ?? 1), withMacAddress: realMacAddress, withDate: date, withDayRange: offset))
    }
    
    //MARK:- 同步配置
    public func setSynchronizationConfig(closure:@escaping (_ complete:Bool) -> ()){

        swiftSynchronizationConfig = { data in
            closure(data);
        }
        protocol_sync_config_start()
    }
    
    //设置闹钟
    public func updateAlarm(_ macAddress: String? = nil, alarmId: Int16, customAlarm: CustomAlarm, closure: (_ success: Bool)->()){
      
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        let alarmList = coredataHandler.selectAlarm(alarmId: alarmId, withMacAddress: realMacAddress)
        guard !alarmList.isEmpty else {
            closure(false)
            return
        }
        
        let alarm = alarmList[0]
        alarm.hour = Int16(customAlarm.hour)
        alarm.minute = Int16(customAlarm.minute)
        alarm.duration = customAlarm.duration
        alarm.repeatList = Int16(customAlarm.repeatList.reduce(0){$0 | 0x01 << (7 - Int8($1))})
        alarm.synchronize = false
        alarm.type = customAlarm.type
        alarm.id = alarmId
        
        guard coredataHandler.commit() else {
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 添加闹钟
    public func addAlarm(_ macAddress: String? = nil, customAlarm: CustomAlarm, closure: (_ success: Bool, _ alarmId: Int16?)->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false, nil)
            return
        }
        //数据库操作
        guard let alarm = coredataHandler.insertAlarm(withMacAddress: realMacAddress) else{
            closure(false, nil)
            return
        }
        
        updateAlarm(realMacAddress, alarmId: alarm.id, customAlarm: customAlarm){
            success in
            closure(true, alarm.id)
        }
        
        
    }
    
    //MARK:- 获取闹钟
    public func getAlarm(_ macAddress: String? = nil, alarmId: Int16, closure: (Alarm?)->()){
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(nil)
            return
        }
        
        closure(coredataHandler.selectAlarm(alarmId: alarmId, withMacAddress: realMacAddress).first)
    }
    
    //MARK:- 获取所有闹钟
    public func getAllAlarms(closure: ([Alarm])->()){
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure([])
            return
        }
        
        closure(coredataHandler.selectAllAlarm(withMacAddress: realMacAddress))
    }
    
    //同步闹钟数据
    public func setSynchronizationAlarm(_ macAddress: String? = nil, closure:@escaping (_ success:Bool) -> ()){
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
    //1.先清除
        protocol_set_alarm_clean()
    //2.再添加 添加的闹钟是从数据库获取的
        //获取所有闹钟
        let alarmList = coredataHandler.selectAllAlarm(withMacAddress: realMacAddress)
        print("alarmList: \(alarmList)")
        alarmList.forEach(){
            localAlarm in
            var alarm = protocol_set_alarm()
            alarm.hour = UInt8(localAlarm.hour)
            alarm.minute = UInt8(localAlarm.minute)
            alarm.alarm_id = UInt8(localAlarm.id)
            alarm.tsnooze_duration = UInt8(localAlarm.duration)
            alarm.type = UInt8(localAlarm.type)
            alarm.repeat = UInt8(localAlarm.repeatList)
            alarm.status = UInt8(localAlarm.status)
            protocol_set_alarm_add(alarm)
        }
        
    //3.再同步
        swiftSynchronizationAlarm = { complete in
            
            closure(complete)
            let alarmList = self.coredataHandler.selectAllAlarm(withMacAddress: realMacAddress)
            alarmList.forEach(){
                localAlarm in
                localAlarm.synchronize = true
            }
            guard self.coredataHandler.commit() else {
                return
            }
        }
        protocol_set_alarm_start_sync()
    }
    
    //获取总开关状态
    public func getNoticeStatus(_ closure:@escaping (_ status:Bool) -> ()){
        
        swiftGetNoticeStatus = { data in
            guard data.0 == 0x55 else {
                closure(false)
                return
            }
            closure(true)
        }
        
        var ret_code:UInt32 = 0
        vbus_tx_evt(VBUS_EVT_BASE_APP_GET,VBUS_EVT_APP_GET_NOTICE_STATUS,&ret_code);
    }
    
    //打开总开关
    private func setOpenNoticeSwitch(closure:(_ status:Bool) ->()){
        var notice = protocol_set_notice()
        notice.notify_switch = 0x55     //0x55 总开关开 0xAA 总开关关 0x88 设置子开关 0x00 无效
        notice.notify_itme1 = 0x00
        notice.notify_itme2 = 0x00
        notice.call_switch = 0x00
        notice.call_delay = 0x00
        
        let length = UInt32(MemoryLayout<UInt8>.size * 7)
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_NOTICE, &notice, length,&ret_code)
        guard ret_code == 0 else {
            closure(false)
            return
        }
        closure(true)
    }
    
    //MARK:- 设置音乐开关
    public func setMusicSwitch(_ open:Bool, macAddress: String? = nil, closure:@escaping (_ success:Bool) -> ()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var musicOn = protocol_music_onoff()
        musicOn.switch_status = open ? 0xAA :0x55
        
        let length = UInt32(MemoryLayout<UInt8>.size * 3)
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_MUISC_ONOFF, &musicOn, length, &ret_code)
        
        guard ret_code==0 else {
            closure(false)
            return
        }
        
        guard open else {
            closure(false)
            return
        }
        
        setOpenNoticeSwitch(closure: { success in
           
            guard success else{
                return
            }
            //保存音乐开关
            let notice = coredataHandler.selectNotice(withMacAddress: realMacAddress)
            notice?.musicSwitch = open
            guard coredataHandler.commit() else{
                closure(false)
                return
            }
            loop(5, closure: closure)
        })
    }
    
    //MARK:- 设置来电提醒
    public func setCallRemind(_ open:Bool, delay:UInt8, macAddress: String? = nil, closure:@escaping (_ success:Bool)->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        
        var call = protocol_set_notice()
        call.notify_switch = 0x88
        
        let notice = coredataHandler.selectNotice(withMacAddress: realMacAddress)
        call.call_switch = open ? 0x55 :0xAA
        call.call_delay = delay
        call.notify_itme1 = UInt8(notice?.notifyItem0 ?? 0)
        call.notify_itme2 = UInt8(notice?.notifyItem1 ?? 0)
        
        //从数据库查询出提醒模型赋给call,暂时填为0
        let length = UInt32(MemoryLayout<UInt8>.size * 7)
        
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_NOTICE,&call,length,&ret_code)
        
        guard ret_code==0 else {
            closure(false)
            return
        }
        guard open else {
            closure(false)
            return
        }
        print("打开总开关")
        setOpenNoticeSwitch(closure: { success in
            print("打开总开关 \(success)")
            guard success else{
                return
            }
            
            notice?.callSwitch = open
            notice?.callDelay = Int16(delay)
            guard coredataHandler.commit() else{
                closure(false)
                return
            }
            loop(5, closure: closure)
        })
    }
    
    //MARK:- 循环设置总开关5次
    private func loop(_ count: Int, closure: @escaping (_ success:Bool)->()){
        
        guard count > 0 else {
            return
        }
        
        _ = delay(5, task: {
            //调5次
            self.getNoticeStatus({status in
                print("获取总开关状态 \(status)")
                if status{
                    //保存音乐开关到数据库
                    
                    closure(status)
                }else{
                    guard count > 0 else{
                        return
                    }
                    self.loop(count - 1, closure: closure)
                }
            })
        })
    }
    
    //MARK:- 设置智能提醒
    public func setSmartAlart(smart:SmartAlertPrm, macAddress: String? = nil, closure:@escaping (_ success:Bool)->()){
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            closure(false)
            return
        }
        
        var call = protocol_set_notice()
        
        call.notify_switch = 0x88
        
        //从数据库查询出提醒模型赋给call,暂时填为0
        let notice = coredataHandler.selectNotice(withMacAddress: realMacAddress)
        call.notify_itme1 = UInt8(notice?.notifyItem0 ?? 0)
        call.notify_itme2 = UInt8(notice?.notifyItem1 ?? 0)
        call.call_switch = (notice?.callSwitch ?? false) ? 0x55 : 0xAA
        call.call_delay = UInt8(notice?.callDelay ?? 0)
        
        let itmes1: UInt8 = getValue(smart.sms, 1) | getValue(smart.weChat,3) | getValue(smart.qq,4) | getValue(smart.faceBook,6) | getValue(smart.twitter,7)
        let itmes2: UInt8 = getValue(smart.whatsapp,0) | getValue(smart.messenger,1) | getValue(smart.instagram,2) | getValue(smart.linkedIn,3)

        call.notify_itme1 = itmes1
        call.notify_itme2 = itmes2
        
        let length = UInt32(MemoryLayout<UInt8>.size * 7)
        var ret_code:UInt32 = 0
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_NOTICE, &call, length, &ret_code)
        
        guard ret_code==0 else {
            closure(false)
            return
        }
        print("打开总开关")
        setOpenNoticeSwitch(closure: { success in
            print("打开总开关 \(success)")
            guard success else{
                return
            }
            
            notice?.notifyItem0 = Int16(itmes1)
            notice?.notifyItem1 = Int16(itmes2)
            guard coredataHandler.commit() else{
                closure(false)
                return
            }
            loop(5, closure: closure)
        })
    }
    
    private func getValue(_ flag:Bool,_ offset:UInt8) -> UInt8{
        let result = flag ? 0x01 << offset : 0x00
        return result
    }

}


