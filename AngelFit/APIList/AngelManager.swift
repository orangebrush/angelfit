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

public class AngelManager {
    
    typealias alarmBlock1 = ((_ date:Date)->())
    typealias alarmBlock2 = ((_ success:Date)->())
    typealias alarmBlock3 = ((_ date:Date)->())
    
//    var actionMap:[ActionType:[UInt8]]?{
//        let map:[ActionType:[UInt8]] = [.binding:[0x04, 0x01, 0x01, 0x83, 0x55, 0xaa],
//                                        .unbinding:[0x04, 0x02, 0x55, 0xaa, 0x55, 0xaa],
//                                        .responceType:[0x07, 0xA1, 0x01],
//                                        .activated:[0x02, 0xA1]]
//        return map
//    }
    
    private var peripheral: CBPeripheral?       //当前设备
    public var macAddress: String?             //当前设备macAddress
    
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
    class func share() -> AngelManager?{
        return __once
    }
    
    convenience init(currentPeripheral existPeripheral: CBPeripheral) {
        self.init()
        
        peripheral = existPeripheral
    }
    
    init(){
        //初始化获取macAddress
        getMacAddress(){
            errorCode, data in
            if errorCode == ErrorCode.success{
                self.macAddress = data
            }
        }
    }
    
    //MARK:- 从数据库获取数据
    public func getModelFromStore(withDataResult dataModel: NSManagedObject.Type, userId ID: Int16 = 1, withDate date: Date = Date(), withMacAddress macAddress: String, closure: @escaping (_ errorCode:Int16 , _ dataResult: DataResult<NSManagedObject>)->()){
        
        switch dataModel {
        case is Device:
            break
        default:
            break
        }
    }
    
    //获取mac地址
    public func getMacAddress( closure: @escaping (_ errorCode:Int16 ,_ value: String)->()){
        getLiveDataFromBring(withActionType: .macAddress, closure: closure)

    }
    
    //获取设备信息
    public func getDeviceInfo(closure : @escaping (_ errorCode:Int16 ,_ value: String)->()){
        getLiveDataFromBring(withActionType: .deviceInfo, closure: closure)
    }
    
    //获取功能列表
    public func getFuncTable(closure : @escaping (_ errorCode:Int16 ,_ value: String)->()){
        getLiveDataFromBring(withActionType: .funcTable, closure: closure)
    }
    
    //获取实时数据
    public func getLiveData(closure : @escaping (_ errorCode:Int16 ,_ value: String)->()){
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
                device?.version = "\(deviceInfo.version)"
                device?.pairFlag = "\(deviceInfo.pair_flag)"
                device?.rebootFlag = Int16(deviceInfo.reboot_flag)
                device?.model = "\(deviceInfo.mode)"
                device?.deviceId = Int16(deviceInfo.device_id)
                guard self.coredataHandler.commit() else{
                    closure(ErrorCode.failure, "commit fail")
                    return
                }
                
                closure(ErrorCode.success, "\(deviceInfo)")
            }
            
            var ret_code:UInt32 = 0
            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_DEVICE_INFO, &ret_code)
            
        case .funcTable:
            swiftFuncTable = { data in
                
                let funcTableStruct:protocol_get_func_table = data.assumingMemoryBound(to: protocol_get_func_table.self).pointee
                
                let funcTable = funcTableStruct
                
                closure(ErrorCode.success, "\(funcTable)")
            }
            var ret_code:UInt32 = 0
            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_FUNC_TABLE_USER, &ret_code)
            
        case .liveData:
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
        coredataHandler.commit()
        
        closure(true)
    }
    
    //MARK:- 设置久坐提醒
    public func setLongSit(_ sit:LongSitModel, macAddress: String? = nil, closure:(_ success:Bool) ->()){
        
        var long_sit:protocol_long_sit = protocol_long_sit()
        
        long_sit.start_hour = sit.startHour
        long_sit.start_minute = sit.startMinute
        long_sit.end_hour = sit.endHour
        long_sit.end_minute = sit.endMinute
        long_sit.interval = sit.duringTime
        
        //0,1,2,3,4,5,6 日。。。六
        var val = sit.weekdayList.reduce(0){$0 | ($1 == 0 ? 0x1 : 0x01 << UInt8(7 - $1))}
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
            case .timeFormat_12:
                setUnit.is_12hour_format = 0x01
                unit?.timeFormat = 0x01
            default:
                break
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
    public func getUnit(_ macAddress: String? = nil) -> Unit?{
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            return nil
        }
        return coredataHandler.selectUnit(withMacAddress: realMacAddress)
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
        coredataHandler.commit()
        
        closure(true)
    }
    
    //MARK:- 获取是否开启寻找手机
    public func getFindPhone(_ macAddress: String? = nil) -> Bool?{
        
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            return nil
        }
        
        guard let device = coredataHandler.selectDevice(withMacAddress: realMacAddress) else{
            return nil
        }
        return device.findPhoneSwitch
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
    public func getQuickSOSSwitch(_ macAddress: String? = nil) -> Bool?{
        
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            return nil
        }
        
        guard let device = coredataHandler.selectDevice(withMacAddress: realMacAddress) else{
            return nil
        }
        return device.sos
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
    public func getWristRecognition(_ macAddress: String? = nil) -> HandGesture?{
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            return nil
        }
        
        return coredataHandler.selectHandGesture(withMacAddress: realMacAddress)
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
    public func getHeartRateInterval(_ macAddress: String? = nil) -> HeartInterval?{
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            return nil
        }
        
        return coredataHandler.selectHeartInterval(withMacAddress: realMacAddress)
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
    public func getHand(_ macAddress: String? = nil) -> Bool?{
        
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            return nil
        }
        
        guard let handGesture = coredataHandler.selectHandGesture(withMacAddress: realMacAddress) else {
            return nil
        }
        
        return handGesture.leftHand
    }
    
    //MARK:- 设置心率模式
    public func setHeartRateMode(_ heartRateMode: HeartRateMode, macAddress: String? = nil, closure:(_ success:Bool) ->() ){
        
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
    public func getHeartRateMode(_ macAddress: String? = nil) -> HeartRateMode?{
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            return nil
        }
        
        guard let heartInterval = coredataHandler.selectHeartInterval(withMacAddress: realMacAddress) else {
            return nil
        }
        let result = heartInterval.heartRateMode
        switch result {
        case 0x88:
            return HeartRateMode.auto
        case 0x55:
            return HeartRateMode.close
        case 0xAA:
            return HeartRateMode.manual
        default:
            return nil
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
    public func getLangscape(_ macAddress: String? = nil) -> Bool?{
        //判断mac地址是否存在
        var realMacAddress: String!
        if let md = macAddress{
            realMacAddress = md
        }else if let md = self.macAddress{
            realMacAddress = md
        }else{
            return nil
        }
        
        guard let device = coredataHandler.selectDevice(withMacAddress: realMacAddress) else {
            return nil
        }
        
        return device.landscape
    }
    
    //MARK:- 同步数据
    /*
     *  status 是否同步完成
     *  percent 同步百分比
     */
    public func setSynchronizationHealthData(closure:@escaping (_ status:Bool, _ percent:Int16) -> ()){
        
        swiftSynchronizationHealthData = { data in
            closure(data.0,Int16(data.1))
        }
        swiftReadSportData = { data in
            let sportData:protocol_health_resolve_sport_data_s = data.assumingMemoryBound(to: protocol_health_resolve_sport_data_s.self).pointee
            //处理sportData
            
        }
        swiftReadSleepData = { data in
            let sleepData:protocol_health_resolve_sleep_data_s = data.assumingMemoryBound(to: protocol_health_resolve_sleep_data_s.self).pointee
            //处理sportData
        }
        swiftReadHeartRateData = { data in
            let heartRateData:protocol_health_resolve_heart_rate_data_s = data.assumingMemoryBound(to: protocol_health_resolve_heart_rate_data_s.self).pointee
        }
        
        protocol_health_sync_start();
    }
    
    //同步配置
    public func setSynchronizationConfig(closure:@escaping (_ status:Bool) -> ()){
    
        swiftSynchronizationConfig = { data in
            closure(data);
        }
        protocol_sync_config_start()
    }
    
    //设置闹钟
    public func setAlarm(){
      //数据库操作
    }
    
    //同步闹钟数据
    public func setSynchronizationAlarm(closure:@escaping (_ status:Bool) -> ()){
    //1.先清除
        protocol_set_alarm_clean()
    //2.再添加 添加的闹钟是从数据库获取的
        var alarm:protocol_set_alarm = protocol_set_alarm.init()
        alarm.hour = 12
        protocol_set_alarm_add(alarm)
        swiftSynchronizationAlarm = { data in
        closure(true)
        }
        
    //3.再同步
        protocol_set_alarm_start_sync()
    }
    
    //获取总开关状态
    public func getNoticeStatus(wirhPAram closure:@escaping (_ status:Bool) -> ()){
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
    public func setOpenNoticeSwitch(closure:(_ status:Bool) ->()){
        var ret_code:UInt32 = 0
        var notice:protocol_set_notice = protocol_set_notice.init()
        notice.notify_switch = 0x55
        notice.notify_itme1 = 0x00
        notice.notify_itme2 = 0x00
        notice.call_switch = 0x00
        notice.call_delay = 0x00
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*7)
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_NOTICE, &notice, length,&ret_code)
        guard ret_code == 0 else {
            closure(false)
            return
        }
        closure(true)
        
    }
    
    //设置音乐开关
    public func setMusicSwitch(withParam isOpen:Bool , closure:@escaping (_ success:Bool) -> ()){
        
        var ret_code:UInt32 = 0
        
        var musicOn:protocol_music_onoff = protocol_music_onoff.init()
        
        musicOn.switch_status = isOpen ? 0xAA :0x55
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*3)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_MUISC_ONOFF,&musicOn,length,&ret_code)
        
        guard ret_code==0 else {
            closure(false)
            return
        }
        guard isOpen else {
            closure(false)
            return
        }
        print("打开总开关")
        setOpenNoticeSwitch(closure: { notice in
            print("打开总开关 \(notice)")
            _ = delay(30, task: {
                
                self.getNoticeStatus(wirhPAram: {status in
                    print("获取总开关状态 \(status)")
                    closure(status)
                })
            })
        })
        
    }
    //设置来电提醒
    public func setCallRemind(withParam isOpen:Bool , delay:UInt8 , closure:@escaping (_ success:Bool)->()){
        var ret_code:UInt32 = 0
        
        var call:protocol_set_notice = protocol_set_notice.init()
        
        call.notify_switch = 0x88
        
        call.call_switch = isOpen ? 0x55 :0xAA
        
        call.call_delay = delay
        
        //从数据库查询出提醒模型赋给call,暂时填为0
        //...
        
        call.notify_itme1 = 0x00
        call.notify_itme2 = 0x00
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*7)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_NOTICE,&call,length,&ret_code)
        
        guard ret_code==0 else {
            closure(false)
            return
        }
        guard isOpen else {
            closure(false)
            return
        }
        print("打开总开关")
        
        setOpenNoticeSwitch(closure: {_ in
        
        })
    }
    public func setSmartAlart(withParam smart:SmartAlertPrm , closure:(_ success:Bool)->()){
        var ret_code:UInt32 = 0
        
        var call:protocol_set_notice = protocol_set_notice.init()
        
        call.notify_switch = 0x88
        
        //从数据库查询出提醒模型赋给call,暂时填为0
        //...
        call.call_switch = 0x00
        call.call_delay = 0x00
        
        let itmes1:UInt8 = getValue(smart.sms, 1) | getValue(smart.weChat,3) | getValue(smart.qq,4) | getValue(smart.faceBook,6) | getValue(smart.twitter,7)
        
        
        let itmes2:UInt8 = getValue(smart.whatsapp,0) | getValue(smart.messenger,1) | getValue(smart.instagram,2) |
        getValue(smart.linkedIn,3)

        
        call.notify_itme1 = itmes1
        call.notify_itme2 = itmes2
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*7)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_NOTICE,&call,length,&ret_code)
        
        guard ret_code==0 else {
            closure(false)
            return
        }
        print("打开总开关")
        
        setOpenNoticeSwitch(closure: {_ in
            
        })

    
    }
    private func getValue(_ a:Bool,_ i:UInt8) -> UInt8{
        let result = a ? 0x01 << i :0x00 << i
        return result
    }

}


