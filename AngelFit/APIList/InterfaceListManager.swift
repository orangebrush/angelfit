//
//  InterfaceListHander.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/16.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
//手环模式
public enum BringType{
    case unbind //没有绑定
    case bind   //已经绑定
    case ota    //升级模式
}
//个人信息
public struct UserInfoPrm {
    var height:UInt8 = 0
    var weight:UInt16 = 0
    var gender:UInt8 = 0   //性别 1:男 0:女
    var year:UInt16 = 0    //生日
    var month:UInt8 = 0
    var day:UInt8 = 0
}
//久坐提醒
public struct LongSitPrm {
    var startHour:UInt8 = 0        //开始时间
    var startMinute:UInt8 = 0
    var endHour:UInt8 = 0          //结束时间
    var endMinute:UInt8 = 0
    var interval:UInt16 = 0        //间隔
    var repetitions:UInt16 = 0     //重复
    var on:UInt8 = 0               //开关
    var repeatArray = [Int]()      //星期几响应数组
}
//目标
public struct GoalDataPrm {
    var type:UInt8 = 0             //目标类型 00步数,01 卡路里,02 距离
    var step:UInt32 = 0            //步数目标
    var hour:UInt8 = 0             //睡眠目标小时
    var minute:UInt8 = 0           //睡眠目标分钟
}
public struct DoNotDisturbPrm {
    var isOpen:Bool = false
    var startHour:UInt8 = 0
    var startMinute:UInt8 = 0
    var endHour:UInt8 = 0
    var endMinute:UInt8 = 0
}
//心率区间
public struct HeartIntervalPrm {
    var burnFatThreshold:UInt8 = 0
    var aerobicThreshold:UInt8 = 0
    var limitThreshold:UInt8   = 0
}
//从手环端获取数据
public enum ActionType {
    case macAddress     //mac地址
    case deviceInfo     //设备信息
    case liveData       //实时数据
    case funcTable      //功能列表
}
public struct SmartAlertPrm {
    var sms:Bool = false
    var faceBook:Bool = false
    var weChat:Bool = false
    var qq:Bool = false
    var twitter:Bool = false
    var whatsapp:Bool = false
    var linkedIn:Bool = false
    var instagram:Bool = false
    var messenger:Bool = false  //FaceBookMessenger
}

//设置命令
public enum CommondType{
    case setTime        //设置时间
}
//data
public enum DataResult<NSManagedObject>{
    case user(User)
    case device(Device)
    case sportData(SportData)
    case sleepData(SleepData)
    case heartRateData(HeartRateData)
}

public class InterfaceListManager {
    
    public init() {
        
    }
    
    private lazy var coredataHandler = {
        return CoreDataHandler()
    }()
    
    //MARK:- 从数据库获取数据
    public func getModelFromStore(withDataResult dataModel: NSManagedObject.Type, param: Any?, closure: @escaping (_ errorCode:Int16 , _ dataResult: DataResult<NSManagedObject>)->()){
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
    
    //MARK:- 从手环端获取
    private func getLiveDataFromBring(withActionType actionType:ActionType , closure: @escaping (_ errorCode:Int16 ,_ value: String) ->()){
        switch actionType {
        case .macAddress:
            swiftMacAddress = { data  in
                
                let macStruct:protocol_device_mac = data.assumingMemoryBound(to: protocol_device_mac.self).pointee
                
                let macCList = macStruct.mac_addr
                
                let macList = [macCList.0, macCList.1, macCList.2, macCList.3, macCList.4, macCList.5]
                
                let macAddress = macList.map(){String($0,radix:16)}.reduce(""){$0+$1}.uppercased()
                
                //保存macAddress到数据库
                let device = self.coredataHandler.insertDevice(withMacAddress: macAddress)
                
                closure(0,macAddress)
            }
            var ret_code:UInt32 = 0
            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_APP_GET_MAC,&ret_code);
            
        case .deviceInfo:
            swiftDeviceInfo = { data in
                
                let deviceInfoStruct:protocol_device_info = data.assumingMemoryBound(to: protocol_device_info.self).pointee
                
                let deviceInfo = deviceInfoStruct
                
                closure(0,"\(deviceInfo)")
            }
            var ret_code:UInt32 = 0
            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_DEVICE_INFO,&ret_code)
            
        case .funcTable:
            swiftFuncTable = { data in
                
                let funcTableStruct:protocol_get_func_table = data.assumingMemoryBound(to: protocol_get_func_table.self).pointee
                
                let funcTable = funcTableStruct
                
                closure(0,"\(funcTable)")
            }
            var ret_code:UInt32 = 0
            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_FUNC_TABLE_USER,&ret_code)
            
        case .liveData:
            swiftLiveData = { data in
                
                let liveDataStruct:protocol_start_live_data = data.assumingMemoryBound(to: protocol_start_live_data.self).pointee
                
                let liveData = liveDataStruct
                
                closure(0,"\(liveData)")
            }
            var ret_code:UInt32 = 0
            vbus_tx_evt(VBUS_EVT_BASE_APP_GET, VBUS_EVT_APP_GET_LIVE_DATA,&ret_code)
     
        }
    }
    //MARK:- 设置手环端命令
    //设置手环模式
    public func setBringMode(withParam mode:BringType , clourse:(_ success:Bool) ->()){
        var ret_code:UInt32 = 0
        switch mode {
            
        case .unbind:
            protocol_set_mode(PROTOCOL_MODE_UNBIND)
        case .bind:
            protocol_set_mode(PROTOCOL_MODE_BIND)
        case .ota:
            vbus_tx_evt(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_OTA_START, &ret_code)
            
            if ret_code == 0 {
                protocol_set_mode(PROTOCOL_MODE_OTA)
            }
        }
    }
    
    public func setTime() -> UInt32{
        
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: Date())
        
        var time:protocol_set_time = protocol_set_time.init()
        
        time.year =   UInt16(components.year!)
        
        time.month =  UInt8(components.month!)
        
        time.day =    UInt8(components.day!)
        
        time.hour =   UInt8(components.hour!)
        
        time.minute = UInt8(components.minute!)
        
        time.second = UInt8(components.second!)
        
        time.week =   UInt8(components.weekday!)
        
        let length:UInt32 = UInt32(MemoryLayout<UInt16>.size+MemoryLayout<UInt8>.size*8)
        
        var ret_code:UInt32 = 0
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_TIME, &time, length,&ret_code);
        
        return ret_code
    }
    
    public func setUserInfo(withParam user:UserInfoPrm) -> UInt32{
        
        var userInfo:protocol_set_user_info = protocol_set_user_info.init()
        
        userInfo.heigth = user.height
        
        userInfo.weight = user.weight*100
        
        userInfo.gender = user.gender
        
        userInfo.year = user.year
        
        userInfo.monute = user.month
        
        userInfo.day = user.day
        
        var ret_code:UInt32 = 0
        
        let length:UInt32 = UInt32(MemoryLayout<UInt16>.size+MemoryLayout<UInt8>.size*7)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_USER_INFO,&userInfo,length,&ret_code)
        
        
        guard ret_code==0 else {
            return ret_code
        }
        //保存到数据库
        //...
        return ret_code
    }
    //设置久坐提醒
    public func setLongSit(withParam sit:LongSitPrm) -> UInt32{
        
        var long_sit:protocol_long_sit = protocol_long_sit()
        
        long_sit.start_hour = sit.startHour
        long_sit.start_minute = sit.startMinute
        long_sit.end_hour = sit.endHour
        long_sit.end_minute = sit.endMinute
        long_sit.interval = sit.interval
        
        var val:UInt16 = 0
        //0,1,2,3,4,5,6
        sit.repeatArray.forEach(){
            i in
            val = val | 0x1 << UInt16(i)
        }
     
        val = val | (UInt16(sit.on) << 0);
        
        long_sit.repetitions = val;
        
        var ret_code:UInt32 = 0
        
        let length:UInt32 = UInt32(MemoryLayout<UInt16>.size*2+MemoryLayout<UInt8>.size*6)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_LONG_SIT, &long_sit, length,&ret_code)
        if (ret_code==0) {
           //保存数据库
        }
        return ret_code
    }
    //设置公英制
    //param metric true为公制，fasle为英制
    public func setMetric(withParam metric:Bool) -> UInt32{
        var ret_code:UInt32 = 0
        
        var setUnit:protocol_set_uint = protocol_set_uint.init()
        switch metric {
        case true:
            setUnit.dist_uint = 0x01
            setUnit.weight_uint = 0x01
            setUnit.temp = 0x01
            setUnit.language = 0x01
            setUnit.is_12hour_format = 0x01
        case false:
            setUnit.dist_uint = 0x02
            setUnit.weight_uint = 0x02
            setUnit.temp = 0x02
            setUnit.language = 0x02
            setUnit.is_12hour_format = 0x02
        }
        /*
         stride 为步长，根据身高和男女运算，详情见协议 70是默认的
         */
        setUnit.stride = 70
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*8)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_UINT, &setUnit, length,&ret_code)

        if ret_code == 0 {
        //保存数据库
        }
        
        return ret_code
    }
    //设置目标
    public func setGoal(withParam goal:GoalDataPrm , closure: @escaping (_ success:Bool) ->()){
        var ret_code:UInt32 = 0
        
        var setGoal:protocol_set_sport_goal = protocol_set_sport_goal.init()
        
        setGoal.type = goal.type
        setGoal.data = goal.step
        setGoal.sleep_hour = goal.hour
        setGoal.sleep_minute = goal.minute
        
        let length:UInt32 = UInt32(MemoryLayout<UInt32>.size+MemoryLayout<UInt8>.size*5)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_SPORT_GOAL, &setGoal, length,&ret_code)
        
        guard ret_code == 0 else {
            closure(false)
            return
        }

        //保存数据库
        closure(true)

    }
    
    //设置拍照开关
    /*
       private func getLiveDataFromBring(withActionType actionType:ActionType , closure: @escaping (_ errorCode:Int16 ,_ value: String) ->())
     */
    public func setCamera(withParam isOpen:Bool , closure: @escaping (_ success:Bool) ->()){
        swiftGetCameraSignal = { data in
            
            if data == VBUS_EVT_APP_BLE_TO_APP_PHOTO_SINGLE_SHOT {
                closure(true)
            }else{
                closure(false)
            }
        }
        var ret_code:UInt32 = 0
        var evt_type:VBUS_EVT_TYPE = VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP
        
        if isOpen == true {
            evt_type = VBUS_EVT_APP_APP_TO_BLE_PHOTO_START;
        }
        else if isOpen == false {
            evt_type = VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP;
        }
        vbus_tx_evt(VBUS_EVT_BASE_APP_SET, evt_type, &ret_code);
        
    }
    
    //设置寻找手机 timeOut 超时时间
    public func setFindPhone(withParam isOpen:Bool ,andTimeOut timeOut:UInt8 , closure: (_ success:Bool) ->()){
        var ret_code:UInt32 = 0
        
        var findPhone:protocol_find_phone = protocol_find_phone.init()
        
        findPhone.status = isOpen ? 0xAA : 0x55
        
         let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*4)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_FIND_PHONE,&findPhone,length, &ret_code);
        
        guard ret_code==0 else {
            closure(false)
            return
        }
        //保存数据库
        closure(true)
    }
    //设置一键还原
    public func setVistaGhost(closure: (_ success:Bool)->()){
        var ret_code:UInt32 = 0
        
        vbus_tx_evt(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_DEFAULT_CONFIG, &ret_code)
        
        closure(true)
    }
    //设置一键呼叫
    public func setOneKeyCall(withParam isOpen:Bool ,closure:(_ success:Bool) ->()){
       var ret_code:UInt32 = 0
        
        var oneKey:protocol_set_onekey_sos = protocol_set_onekey_sos.init()
        
        oneKey.on_off = isOpen ? 0xAA : 0x55
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*3)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_ONEKEY_SOS,&oneKey,length, &ret_code)
        
        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        closure(true)
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
    
    //打开抬腕识别
    public func setWristRecognition(withParam isOpen:Bool ,secondLight second:UInt8 ,closure: (_ success:Bool)->()){
        var wrist:protocol_set_up_hand_gesture = protocol_set_up_hand_gesture.init()
        
        var ret_code:UInt32 = 0
        
        wrist.show_second = second
        
        wrist.on_off = isOpen ? 0xAA : 0x55
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*4)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_UP_HAND_GESTURE,&wrist,length,&ret_code);

        guard ret_code == 0 else {
            closure(false)
            return
        }

        //保存数据库
        //...
        closure(true)
    }
    
    //设置勿扰模式
    public func setDoNotDisturb(withParam donnot:DoNotDisturbPrm , closure:(_ success:Bool)->()){
        var disturb:protocol_do_not_disturb = protocol_do_not_disturb.init()
        
        disturb.switch_flag = donnot.isOpen ? 0xAA :0x55
        
        disturb.start_hour = donnot.startHour
        
        disturb.start_minute = donnot.startMinute
        
        disturb.end_hour = donnot.endHour
        
        disturb.end_minute = donnot.endMinute
        
        var ret_code:UInt32 = 0
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*7)
        
        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_DO_NOT_DISTURB,&disturb,length,&ret_code);

        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        closure(true)
    }
    
    //设置心率区间
    
    public func setHeartRateInterval(withPAram hinterval:HeartIntervalPrm ,closure:(_ success:Bool) -> ()){
        var interval:protocol_heart_rate_interval = protocol_heart_rate_interval.init()
        
        interval.aerobic_threshold = hinterval.aerobicThreshold
        
        interval.burn_fat_threshold = hinterval.burnFatThreshold
        
        interval.limit_threshold = hinterval.limitThreshold
        
        var ret_code:UInt32 = 0
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*5)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_HEART_RATE_INTERVAL,&interval,length,&ret_code);

        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        closure(true)
    }
    
    //设置左右手穿戴
    /*handtype true为右手*/
    public func setHandType(withParam handType:Bool , closure:(_ success:Bool)->()){
        var ret_code:UInt32 = 0

        var handle:protocol_set_handle = protocol_set_handle.init()
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*3)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_HAND,&handle,length,&ret_code)
        
        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        closure(true)

    }
    
    //设置心率模式
    public func setHeartRateMode(withPAram isAuto:Bool , closure:(_ success:Bool) ->() ){
        var ret_code:UInt32 = 0
        
        var mode:protocol_heart_rate_mode = protocol_heart_rate_mode.init()

        mode.mode = isAuto ? 0x88 : 0x55
        
        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*3)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_HEART_RATE_MODE,&mode,length,&ret_code);

        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        closure(true)
    }
    
    public func setScreenMode(withParam isLand:Bool , closure:(_ success:Bool) ->()){
        var ret_code:UInt32 = 0
        
        var mode:protocol_display_mode = protocol_display_mode.init()
        
        mode.mode = isLand ? 0x01 : 0x02

        let length:UInt32 = UInt32(MemoryLayout<UInt8>.size*3)

        vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_DISPLAY_MODE,&mode,length,&ret_code);
 
        guard ret_code == 0 else {
            closure(false)
            return
        }
        //保存数据库
        closure(true)
        
    }
    //同步数据
    /*
     *  status 是否同步完成
     *  percent 同步百分比
     */
    public func setSynchronizationHealthData(closure:@escaping (_ status:Bool , _ percent:Int16) -> () ){
        swiftSynchronizationHealthData = { data in
            closure(data.0,Int16(data.1))
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


