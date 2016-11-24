//
//  AngelModel.swift
//  AngelFit
//
//  Created by YiGan on 21/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData

//错误码
//#define SUCCESS					0
//#define ERROR_NO_MEM			4
//#define ERROR_NOT_FIND			5
//#define ERROR_NOT_SUPPORTED		6
//#define ERROR_INVALID_PARAM		7
//#define ERROR_INVALID_STATE		8
//#define ERROR_INVALID_LENGTH 	9
//#define ERROR_INVALID_FLAGS 	10
//#define ERROR_INVALID_DATA		11
//#define ERROR_DATA_SIZE			12
//#define ERROR_TIMEOUT			13
//#define ERROR_NULL				14
//#define ERROR_FORBIDDEN			15
//#define ERROR_BUSY				17
//#define ERROR_LOW_BATT          18
public struct ErrorCode{
    static let success: Int16 = 0
    static let failure: Int16 = 14
}

//手环模式
public enum BandMode{
    case unbind         //没有绑定
    case bind           //已经绑定
    case levelup        //升级模式
}
//个人信息
public struct UserInfoModel {
    public var height:UInt8 = 0
    public var weight:UInt16 = 0
    public var gender:UInt8 = 0        //性别 1:男 0:女
    public var birthYear:UInt16 = 0    //生日
    public var birthMonth:UInt8 = 0
    public var birthDay:UInt8 = 0
    public init(){}
}
//久坐提醒
public struct LongSitModel {
    public var startHour:UInt8 = 0             //开始时间
    public var startMinute:UInt8 = 0
    public var endHour:UInt8 = 0               //结束时间
    public var endMinute:UInt8 = 0
    public var duringTime:UInt16 = 0           //间隔
    public var isOpen = false                //开关
    public var weekdayList = [Int]()           //星期几响应数组   日 0 一 1 。。。 六 6
    public init(){
        
    }
}
//目标
public struct GoalDataModel {
    public var type:UInt8 = 0              //目标类型 00步数,01 卡路里,02 距离
    public var value:UInt32 = 0             //目标
    public var sleepHour:UInt8 = 0             //睡眠目标小时
    public var sleepMinute:UInt8 = 0           //睡眠目标分钟
    public init(){
        
    }
}
//勿扰模式
public struct SilentModel {
    public var isOpen = false
    public var startHour:UInt8 = 0
    public var startMinute:UInt8 = 0
    public var endHour:UInt8 = 0
    public var endMinute:UInt8 = 0         //Silent
    public init(){}
}
//心率区间
public struct HeartIntervalModel {
    var burnFat: UInt8 = 0
    var aerobic: UInt8 = 0
    var limit: UInt8   = 0
}

//心率模式
public enum HeartRateMode {
    case manual
    case auto
    case close
}

//从手环端获取数据
public enum ActionType {
    case macAddress     //mac地址
    case deviceInfo     //设备信息
    case liveData       //实时数据
    case funcTable      //功能列表
}

public struct SmartAlertPrm {
    public var sms = false
    public var faceBook = false
    public var weChat = false
    public var qq = false
    public var twitter = false
    public var whatsapp:Bool = false
    public var linkedIn:Bool = false
    public var instagram:Bool = false
    public var messenger:Bool = false  //FaceBookMessenger
    public init(){}
}

//设置命令
public enum CommondType{
    case setTime        //设置时间
}

//公英制
public enum UnitType{
    case distance_KM
    case distance_MI
    case weight_KG
    case weight_LB
    case temp_C
    case temp_F
    case langure_ZH
    case langure_EN
    case timeFormat_24
    case timeFormat_12
}

//健康数据
public enum HealthDataType{
    case sport
    case sleep
    case heartRate
}

//闹钟
//设置闹钟
public struct CustomAlarm{
    public var id: Int16 = 0
    public var duration: Int16 = 0     //贪睡
    public var status: Int16 = 0x55    //状态
    public var type: Int16 = 0x07      //类型
    public var hour: UInt8 = 0
    public var minute: UInt8 = 0
    public var repeatList = [UInt8]()  //0总开关 1周一 ... 7周日
    public init(){
        
    }
}
