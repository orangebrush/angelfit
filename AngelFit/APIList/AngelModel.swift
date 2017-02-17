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
    public static let success: Int16 = 0
    public static let failure: Int16 = 14
}

//手环模式
@objc public enum BandMode: Int{
    case unbind         //没有绑定
    case bind           //已经绑定
    case levelup        //升级模式
}
//个人信息
public class UserInfoModel {
    public var height:UInt8 = 0
    public var weight:UInt16 = 0
    public var gender:UInt8 = 0        //性别 1:男 0:女
    public var birthYear:UInt16 = 0    //生日
    public var birthMonth:UInt8 = 0
    public var birthDay:UInt8 = 0
    public init(){}
}
//久坐提醒
public class LongSitModel {
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
public class GoalDataModel {
    public var type:UInt8 = 0              //目标类型 00步数,01 卡路里,02 距离
    public var value:UInt32 = 0             //目标
    public var sleepHour:UInt8 = 0             //睡眠目标小时
    public var sleepMinute:UInt8 = 0           //睡眠目标分钟
    public init(){
        
    }
}
//勿扰模式
public class SilentModel {
    public var isOpen = false
    public var startHour:UInt8 = 0
    public var startMinute:UInt8 = 0
    public var endHour:UInt8 = 0
    public var endMinute:UInt8 = 0         //Silent
    public init(){}
}
//心率区间
public class HeartIntervalModel {
    public var burnFat: UInt8 = 0
    public var aerobic: UInt8 = 0
    public var limit: UInt8   = 0
    public init(){}
}

//心率模式
@objc public enum HeartRateMode :Int{
    case manual
    case auto
    case close
}

//从手环端获取数据
@objc public enum ActionType: Int {
    case macAddress     //mac地址
    case deviceInfo     //设备信息
    case liveData       //实时数据
    case funcTable      //功能列表
}

public class SmartAlertPrm {
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
@objc public enum CommondType: Int{
    case setTime        //设置时间
}

//公英制
@objc public enum UnitType: Int{
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
@objc public enum HealthDataType: Int{
    case sport
    case sleep
    case heartRate
}

//闹钟
//设置闹钟
public class CustomAlarm{
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


// MARK:- 交换数据(手环端发起)
public enum SwitchStartStatus: UInt8{
    case normal = 0
    case conflicts
    case batteryLow
}


//交换数据开始
public class SwitchStart {
    public var date = Date()    //开始时间格式 同时也是记录的轨迹id eg:yyyyMMddHHmmss
    /*
     Target_type:目标类型，(0x00:无目标， 0x01:重复次数，单位:次， 0x02:距离，单位:
     
     米， 0x03:卡路里，单位:大卡，0x04:时长，单位:分钟 ) Type:运动类型(0x00:无， 0x01:走路， 0x02:跑步， 0x03:骑行，0x04:徒步， 0x05: 游泳， 0x06:爬山， 0x07:羽毛球， 0x08:其他， 0x09:健身， 0x0A:动感单车， 0x0B:椭圆机， 0x0C:跑步机， 0x0D:仰卧起坐， 0x0E:俯卧撑， 0x0F:哑铃， 0x10:举重， 0x11:健身操， 0x12:瑜伽， 0x13:跳绳， 0x14:乒乓球， 0x15:篮球， 0x16:足球 ， 0x17:排球， 0x18:网球， 0x19:高尔夫球， 0x1A:棒球， 0x1B:滑雪， 0x1C:轮滑，0x1D:跳舞)
     */
    public var sportType : UInt8 = 0
    
    public var targetType : UInt8 = 0     //目标类型
    public var targetValue : UInt32 = 0    //目标值
    /*强制开始标志 Force_start:强制开始，0x01:强制开始有效， 0x00:强制开始无效(只有用户可以使用)*/
    public var forceStart : Bool = false
}

//交换数据中
public class SwitchDoing {
    public var date = Date()   //开始时间格式 eg:yyyyMMddHHmmss
    /*
     Flag:0x00:全部有效， 0x01:距离无效，0x02:gps信号弱
     */
    public var flag : UInt8 = 0
    public var duration	: UInt32 = 0        //持续时长
    public var calories	: UInt32 = 0        //卡路里
    public var distance	: UInt32 = 0        //距离(米)
}
//交换中手环回复
public class SwitchDoingReply {
    /*0x01:成功; 0x02:设备没有进入运动模式失败*/
    public var status: UInt8 = 0
    public var step: UInt32 = 0
    public var calories: UInt32 = 0
    public var distance: UInt32 = 0
    public var curHrValue: UInt8 = 0
    public var available: Bool = true
    public var hrValueSerial: UInt8 = 0
    public var hrValue: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = (0,0,0,0,0,0)
}

//暂停或继续交换数据
public class SwitchPauseOrContinue{
    public var date = Date()   //开始时间格式 eg:yyyyMMddHHmmss
}

//结束交换数据
public class SwitchEnd{
    public var date = Date()     //开始时间格式 eg:yyyyMMddHHmmss
    public var durations : UInt32 = 0       //持续时长
    public var calories  : UInt32 = 0
    public var distance  : UInt32 = 0
    public var sportType: UInt32 = 0
    public var isSave   : UInt32 = 0       //是否保存  1 0
}
//结束交换数据回复
public class SwitchEndReply{
     /*0x01:成功; 0x02:设备没有进入运动模式失败*/
    public var endSuccess: Bool = false
    public var step: UInt32 = 0
    public var calories: UInt32 = 0
    public var distance: UInt32 = 0
    public var avgHrValue: UInt8 = 0       //平均心率
    public var maxHrValue: UInt8 = 0       //最大心率
    public var burnFatMins: UInt8 = 0      //燃烧脂肪时长
    public var aerobicMins: UInt8 = 0      //心肺锻炼时长
    public var limitMins: UInt8 = 0        //极限锻炼时长
}


