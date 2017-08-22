//
//  NWH+Device.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
//设备更新参数
public class NWHDeviceParam: NSObject{
    public var deviceId: String?
    public var macAddress: String?
    public var uuid: String?
    public var name: String?
    public var showName: String?
    public var type: Int = 0
    public var batteryType: String?
    public var totalUserdMinutes: Int = 0
}

//设备状态参数
public class NWHDeviceStatusParam: NSObject {
    public var deviceId: String?
    public var batteryStatus: String?
    public var batteryLevel: Int = 0
    public var batteryVoltage: Int = 0
    public var totalUsedMinutes: Int = 0
}
//设备功能列表参数
public class NWHDeviceFunctableParam: NSObject {
    public var deviceId: String?
    public var havePedometer = false
    public var haveSleepMonitor = false
    public var haveTrainingTracking = false
    public var haveRealData = false
    public var haveOta = false
    public var haveHeartRateMonitor = false
    public var haveAncs = false
    public var haveTimeline = false
    public var haveLogin = false
    public var haveAlarm = false
    public var haveCameraControl = false
    public var havePlayMusicControl = false
    public var haveCallNotification = false
    public var haveCallContact = false
    public var haveCallNumber = false
    public var haveMsgNotification = false
    public var haveMsgContact = false
    public var haveMultiSport = false
    public var haveMsgNumber = false
    public var haveMsgContent = false
    public var haveLongSit = false
    public var haveAntiLost = false
    public var haveShortcutCall = false
    public var haveFindPhone = false
    public var haveShortcutReset = false
    public var haveWakeScreenOnWristRaise = false
    public var haveWeatherForecast = false
    public var isHeartRateMonitorSilent = false
    public var haveNotDisturbMode = false
    public var haveScreenDisplayMode = false
    public var haveHeartRateMonitorControl = false
    public var haveAllMsgNotification = false
    public var haveScreenDisplay180Rotate = false
}
//设备交互功能参数
public class NWHDeviceMsgParam: NSObject {
    public var deviceId: String?
    public var isMainOn: Int = 0
    public var isSmsOn: Int = 0
    public var isEmailOn: Int = 0
    public var isQqOn: Int = 0
    public var isWechatOn: Int = 0
    public var isSinaWeiboOn: Int = 0
    public var isFacebookOn: Int = 0
    public var isTwitterOn: Int = 0
    public var isOtherOn: Int = 0
    public var isWhatsappOn: Int = 0
    public var isMessengerOn: Int = 0
    public var isInstagramOn: Int = 0
    public var isLinkedInOn: Int = 0
    public var isCalendarEventOn: Int = 0
    public var isSkypeOn: Int = 0
    public var isAlarmEventOn: Int = 0
    public var isPokemanOn: Int = 0
}
//设备错误日志参数
public class NWHDeviceErrorLogParam: NSObject {
    public var deviceId: String?
    public var errorTimestatmp: Date?
    public var errorType: String?
    public var errorMessage: String?
}
    
public class NWHDevice: NSObject{
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NWHDevice()
    public class func share() -> NWHDevice{
        return __once
    }
    
    //MARK:-新增设备
    /*
     * @param id                require 由设备唯一id,由deviceType,deviceId与macaddress组成
     * @param macAddress        设备物理地址
     * @param uuid              设备uuid
     * @param name              设备名
     * @param showName          显示名
     * @param type              设备类型 NWHDeviceType
     * @param batteryType       电池类型 NWHDeviceBatteryType
     * @param totalUsedMinutes  总共使用分钟数
     */
    public func add(withParam param: NWHDeviceParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [String: Any]()
        guard let id = param.deviceId else {
            closure(0, "id is empty", nil)
            return
        }
        
        dict["id"] = id
        
        if let macaddress = param.macAddress {
            dict["macAddress"] = macaddress
        }
        if let uuid = param.uuid {
            dict["uuid"] = uuid
        }
        if let name = param.name {
            dict["name"] = name
        }
        if let showName = param.showName {
            dict["showName"] = showName
        }

        dict["type"] = "\(param.type)"

        if let batteryType = param.batteryType {
            dict["batteryType"] = batteryType
        }

        dict["totalUsedMinutes"] = "\(param.totalUserdMinutes)"

        Session.session(withAction: Actions.deviceAdd, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-设备更新
    /*
     * params同新增设备
     */
    public func update(withParam param: NWHDeviceParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [String: Any]()
        guard let id = param.deviceId else {
            closure(0, "id is empty", nil)
            return
        }
        
        dict["id"] = id
        
        if let macaddress = param.macAddress {
            dict["macAddress"] = macaddress
        }
        if let uuid = param.uuid {
            dict["uuid"] = uuid
        }
        if let name = param.name {
            dict["name"] = name
        }
        if let showName = param.showName {
            dict["showName"] = showName
        }

        dict["type"] = "\(param.type)"
        
        if let batteryType = param.batteryType {
            dict["batteryType"] = batteryType
        }

        dict["totalUsedMinutes"] = "\(param.totalUserdMinutes)"

        
        Session.session(withAction: Actions.deviceUpdate, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-记录设备信息
    /*
     * @param deviceId          require 由设备唯一id,由deviceType,deviceId与macaddress组成
     * @param batteryStatus     option  电池状态，’N’一般状态，’O’充电状态,’C’充电完成，’L’低电量。
     * @param batteryLevel      option  电量，1-100
     * @param batteryVoltage    option  电压
     * @param totalUsedMinutes  option  已使用时长（单位：分钟）
     */
    public func recordState(withParam param: NWHDeviceStatusParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        var dict = [String: Any]()
        guard let id = param.deviceId else {
            closure(0, "id is empty", nil)
            return
        }
        
        dict["deviceId"] = id
        
        if let batteryStatus = param.batteryStatus {
            dict["batteryStatus"] = batteryStatus
        }

        dict["batteryLevel"] = "\(param.batteryLevel)"

        dict["batteryVoltage"] = "\(param.batteryVoltage)"

        
        dict["totalUsedMinutes"] = "\(param.totalUsedMinutes)"
        
        
        Session.session(withAction: Actions.deviceStatus, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-记录功能列表
    /*
     * @param deviceId                      require 由设备唯一id,由deviceType,deviceId与macaddress组成
     * @param havePedometer                 option  是否有记步功能 "1"：有 “0”：无
     * @param haveSleepMonitor              option  是否有睡眠检测
     * @param haveTrainingTracking          option  是否有睡眠跟踪
     * @param haveRealData                  option  是否有实时数据
     * @param haveOta                       option  是否有升级功能
     * @param haveHeartRateMonitor          option  是否有心率检测
     * @param haveAncs                      option  是否支持同步功能
     * @param haveTimeline                  option  是否有时间轴
     * @param haveLogin                     option  是否有登录
     * @param haveAlarm                     option  是否有闹钟功能
     * @param haveCameraControl             option  是否有拍照控制
     * @param havePlayMusicControl          option  是否有音乐控制
     * @param haveCallNotification          option  是否有来电提醒
     * @param haveCallContact               option  是否有来电联系人功能
     * @param haveCallNumber                option  是否有来电显示
     * @param haveMsgNotification           option  是否有消息提醒
     * @param haveMsgContact                option  是否有消息联系人功能
     * @param haveMultiSport                option  是否有多运动功能
     * @param haveMsgNumber                 option  是否有消息号码显示功能
     * @param haveMsgContent                option  是否显示消息内容
     * @param haveLongSit                   option  是否有久坐功能
     * @param haveAntiLost                  option  是否有防丢提醒
     * @param haveShortcutCall              option  是否有短号功能
     * @param haveFindPhone                 option  是否有寻找手机功能
     * @param haveShortcutReset             option  是否有快捷键功能
     * @param haveWakeScreenOnWristRaise    option  是否有抬腕唤醒功能
     * @param haveWeatherForecast           option  是否有天气功能
     * @param isHeartRateMonitorSilent      option  是否有静息心率检测功能
     * @param haveNotDisturbMode            option  是否有误扰模式功能
     * @param haveScreenDisplayMode         option  是否有屏幕显示模式功能
     * @param haveHeartRateMonitorControl   option  是否有心率控制
     * @param haveAllMsgNotification        option  是否有所有消息通知功能
     * @param haveScreenDisplay180Rotate    option  是否支持横屏
     */
    public func recordFunctable(withParam param: NWHDeviceFunctableParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        var dict: [String: Any] = [
            "havePedometer": param.havePedometer ? "1" : "0",
            "haveSleepMonitor": param.haveSleepMonitor ? "1" : "0",
            "haveTrainingTracking": param.haveTrainingTracking ? "1" : "0",
            "haveRealData": param.haveRealData ? "1" : "0",
            "haveOta": param.haveOta ? "1" : "0",
            "haveHeartRateMonitor": param.haveHeartRateMonitor ? "1" : "0",
            "haveAncs": param.haveAncs ? "1" : "0",
            "haveTimeline": param.haveTimeline ? "1" : "0",
            "haveLogin": param.haveLogin ? "1" : "0",
            "haveAlarm": param.haveAlarm ? "1" : "0",
            "haveCameraControl": param.haveCameraControl ? "1" : "0",
            "havePlayMusicControl": param.havePlayMusicControl ? "1" : "0",
            "haveCallNotification": param.haveCallNotification ? "1" : "0",
            "haveCallContact": param.haveCallContact ? "1" : "0",
            "haveCallNumber": param.haveCallNumber ? "1" : "0",
            "haveMsgNotification": param.haveMsgNotification ? "1" : "0",
            "haveMsgContact": param.haveMsgContact ? "1" : "0",
            "haveMultiSport": param.haveMultiSport ? "1" : "0",
            "haveMsgNumber": param.haveMsgNumber ? "1" : "0",
            "haveMsgContent": param.haveMsgContent ? "1" : "0",
            "haveLongSit": param.haveLongSit ? "1" : "0",
            "haveAntiLost": param.haveAntiLost ? "1" : "0",
            "haveShortcutCall": param.haveShortcutCall ? "1" : "0",
            "haveFindPhone": param.haveFindPhone ? "1" : "0",
            "haveShortcutReset": param.haveShortcutReset ? "1" : "0",
            "haveWakeScreenOnWristRaise": param.haveWakeScreenOnWristRaise ? "1" : "0",
            "haveWeatherForecast": param.haveWeatherForecast ? "1" : "0",
            "isHeartRateMonitorSilent": param.isHeartRateMonitorSilent ? "1" : "0",
            "haveNotDisturbMode": param.haveNotDisturbMode ? "1" : "0",
            "haveScreenDisplayMode": param.haveScreenDisplayMode ? "1" : "0",
            "haveHeartRateMonitorControl": param.haveHeartRateMonitorControl ? "1" : "0",
            "haveAllMsgNotification": param.haveAllMsgNotification ? "1" : "0",
            "haveScreenDisplay180Rotate": param.haveScreenDisplay180Rotate ? "1" : "0"
        ]
        guard let deviceId = param.deviceId else {
            closure(ResultCode.failure, "deviceId is empty", nil)
            return
        }
        dict["deviceId"] = deviceId
        
        Session.session(withAction: Actions.deviceAddFunctable, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-更新功能列表
    /*
     *  同添加功能列表参数
     */
    public func updateFunctable(withParam param: NWHDeviceFunctableParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict: [String: Any] = [
            "havePedometer": param.havePedometer ? "1" : "0",
            "haveSleepMonitor": param.haveSleepMonitor ? "1" : "0",
            "haveTrainingTracking": param.haveTrainingTracking ? "1" : "0",
            "haveRealData": param.haveRealData ? "1" : "0",
            "haveOta": param.haveOta ? "1" : "0",
            "haveHeartRateMonitor": param.haveHeartRateMonitor ? "1" : "0",
            "haveAncs": param.haveAncs ? "1" : "0",
            "haveTimeline": param.haveTimeline ? "1" : "0",
            "haveLogin": param.haveLogin ? "1" : "0",
            "haveAlarm": param.haveAlarm ? "1" : "0",
            "haveCameraControl": param.haveCameraControl ? "1" : "0",
            "havePlayMusicControl": param.havePlayMusicControl ? "1" : "0",
            "haveCallNotification": param.haveCallNotification ? "1" : "0",
            "haveCallContact": param.haveCallContact ? "1" : "0",
            "haveCallNumber": param.haveCallNumber ? "1" : "0",
            "haveMsgNotification": param.haveMsgNotification ? "1" : "0",
            "haveMsgContact": param.haveMsgContact ? "1" : "0",
            "haveMultiSport": param.haveMultiSport ? "1" : "0",
            "haveMsgNumber": param.haveMsgNumber ? "1" : "0",
            "haveMsgContent": param.haveMsgContent ? "1" : "0",
            "haveLongSit": param.haveLongSit ? "1" : "0",
            "haveAntiLost": param.haveAntiLost ? "1" : "0",
            "haveShortcutCall": param.haveShortcutCall ? "1" : "0",
            "haveFindPhone": param.haveFindPhone ? "1" : "0",
            "haveShortcutReset": param.haveShortcutReset ? "1" : "0",
            "haveWakeScreenOnWristRaise": param.haveWakeScreenOnWristRaise ? "1" : "0",
            "haveWeatherForecast": param.haveWeatherForecast ? "1" : "0",
            "isHeartRateMonitorSilent": param.isHeartRateMonitorSilent ? "1" : "0",
            "haveNotDisturbMode": param.haveNotDisturbMode ? "1" : "0",
            "haveScreenDisplayMode": param.haveScreenDisplayMode ? "1" : "0",
            "haveHeartRateMonitorControl": param.haveHeartRateMonitorControl ? "1" : "0",
            "haveAllMsgNotification": param.haveAllMsgNotification ? "1" : "0",
            "haveScreenDisplay180Rotate": param.haveScreenDisplay180Rotate ? "1" : "0"
        ]
        guard let deviceId = param.deviceId else {
            closure(ResultCode.failure, "deviceId is empty", nil)
            return
        }
        dict["deviceId"] = deviceId
        
        Session.session(withAction: Actions.deviceUpdateFunctable, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-记录设备交互功能
    /*
     * @param deviceId              require 由设备唯一id,由deviceType,deviceId与macaddress组成
     * @param isMainOn              option  总开关 "0":无此功能 “1”：开 “2”：关
     * @param isSmsOn               option  短信
     * @param isEmailOn             option  邮件
     * @param isQqOn                option  QQ
     * @param isWechatOn            option  微信
     * @param isSinaWeiboOn         option  新浪微博
     * @param isFacebookOn          option  脸书
     * @param isTwitterOn           option  推特
     * @param isOtherOn             option  其他
     * @param isWhatsappOn          option  Whats APP
     * @param isMessengerOn         option  Message
     * @param isInstagramOn         option  instagram
     * @param isLinkedInOn          option  领英
     * @param isCalendarEventOn     option  日历事件
     * @param isSkypeOn             option  skype
     * @param isAlarmEventOn        option  日程
     * @param isPokemanOn           option  pokeman
     */
    public func recordMsg(withParam param: NWHDeviceMsgParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        var dict: [String: Any] = [
            "isMainOn": "\(param.isMainOn)",
            "isSmsOn": "\(param.isSmsOn)",
            "isEmailOn": "\(param.isEmailOn)",
            "isQqOn": "\(param.isQqOn)",
            "isWechatOn": "\(param.isWechatOn)",
            "isSinaWeiboOn": "\(param.isSinaWeiboOn)",
            "isFacebookOn": "\(param.isFacebookOn)",
            "isTwitterOn": "\(param.isTwitterOn)",
            "isOtherOn": "\(param.isOtherOn)",
            "isWhatsappOn": "\(param.isWhatsappOn)",
            "isMessengerOn": "\(param.isMessengerOn)",
            "isInstagramOn": "\(param.isInstagramOn)",
            "isLinkedInOn": "\(param.isLinkedInOn)",
            "isCalendarEventOn": "\(param.isCalendarEventOn)",
            "isSkypeOn": "\(param.isSkypeOn)",
            "isAlarmEventOn": "\(param.isAlarmEventOn)",
            "isPokemanOn": "\(param.isPokemanOn)"
        ]
        guard let deviceId = param.deviceId else {
            closure(ResultCode.failure, "deviceId is empty", nil)
            return
        }
        
        dict["deviceId"] = deviceId

        Session.session(withAction: Actions.deviceUpdateMessage, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-设备错误日志
    /*
     * @param deviceId          require 由设备唯一id,由deviceType,deviceId与macaddress组成
     * @param errorTimestatmp   option  错误发生事件"yyyy-MM-dd HH:mm:ss"
     * @param errorType         option  错误类型
     * @param errorMessage      require 错误内容
     */
    public func recordError(withParam param: NWHDeviceErrorLogParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        guard let deviceId = param.deviceId, let errorMessage = param.errorMessage else {
            closure(ResultCode.failure, "deviceId or errorMessage is empty", nil)
            return
        }
        
        var dict: [String: Any] = [
            "deviceId": deviceId,
            "errorMessage": errorMessage
        ]
        
        if let errorTimestatmp = param.errorTimestatmp {
            dict["errorTimestatmp"] = errorTimestatmp.formatString(with: "yyyy-MM-dd HH:mm:ss")
        }
        if let errorType = param.errorType {
            dict["errorType"] = errorType
        }
        
        Session.session(withAction: Actions.deviceErrorLog, withMethod: Method.post, withParam: dict, closure: closure)
    }
}
