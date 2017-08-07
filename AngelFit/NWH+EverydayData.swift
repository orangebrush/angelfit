//
//  NWH+EverydayData.swift
//  AngelFit
//
//  Created by YiGan on 20/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
//获取最后更新时间参数
public class NWHLastSyncDateParam: NSObject {
    public var userId: String?
    public var deviceId: String?
}

//上传心率参数
public class NWHHeartrateAddParam: NSObject {
    public var deviceId: String?
    public var userId: String?
    public var date: Date?
    public var silentHeartRate: Int = 0
    public var burnFatThreshold: Int = 0
    public var aerobicThreshold: Int = 0
    public var limitThreshold: Int = 0
    public var burnFatMinutes: Int = 0
    public var aerobicMinutes: Int = 0
    public var limitMinutes: Int = 0
    public var itemsStartTime: Date?
    //public var items: [(offset: Int, heartrate: Int)]?
    public var items: [[Int]]?
}
//上传步数参数
public class NWHStepAddParam: NSObject {
    public var deviceId: String?
    public var userId: String?
    public var date: Date?
    public var steps: Int = 0
    public var calories: Int = 0
    public var distances: Int = 0
    public var totalSeconds: Int = 0
    //public var items: [(offset: NSInteger, calories: NSInteger, steps: NSInteger, distanceM: NSInteger)]?
    public var items: [[Int]]?
}
//上传睡眠参数
public class NWHSleepAddParam: NSObject {
    public var deviceId: String?
    public var userId: String?
    public var date: Date?
    public var endedDatetime: Date?
    public var totalMinutes: Int = 0
    public var lightSleepMinutes: Int = 0
    public var deepSleepMinutes: Int = 0
    public var awakeSleepMinutes: Int = 0
    //public var items: [(offset: Int, sleepType: Int)]?
    public var items: [[Int]]?
}
//上传训练参数
public class NWHTrainingAddParam: NSObject {
    public var deviceId: String?
    public var userId: String?
    public var date: Date?
    public var startedAt: Date?
    public var heartRateItemIntervalSeconds: Int = 0
    public var stepItemIntervalSeconds: Int = 0
    public var type: Int = 0
    public var durationSeconds: Int = 0
    public var calories: Int = 0
    public var distances: Int = 0
    public var averageHeartRate: Int = 0
    public var maxHeartRate: Int = 0
    public var burnFatMinutes: Int = 0
    public var aerobicMinutes: Int = 0
    public var limitMinutes: Int = 0
    public var mapSource: String?
    public var steps: [Int]?
    public var heartRates: [Int]?
    //public var gps: [(longtitude: Double, latitude: Double, date: Date)]?
    public var gps: [[AnyObject]]?
}
//下拉心率参数
public class NWHEverydayDataPullParam: NSObject {
    public var deviceId: String?
    public var userId: String?
    public var fromDate: Date?
    public var endDate: Date?
}
public class NWHEverydayData: NSObject {
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NWHEverydayData()
    public class func share() -> NWHEverydayData{
        return __once
    }
    
    //MARK:-获取最后更新日期
    /*
     * @param userId                        require 用户id(服务器会全部转为小写)
     * @param deviceId                      option  设备id(服务器会全部转为大写)
     */
    public func getLastSyncDate(withParam param: NWHLastSyncDateParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        var dict = [String: String]()
        guard let userId = param.userId, let deviceId = param.deviceId else {
            closure(ResultCode.userIdAndDeviceIdEmpty, "userId is empty", nil)
            return
        }
        
        dict["userId"] = userId
        dict["deviceId"] = deviceId
        
        
        Session.session(withAction: Actions.getLastAcynTime, withMethod: Method.get, withParam: dict, closure: closure)
    }
    
    //MARK:-上传心率
    /*
     * [
     *  @param deviceId                     require 设备id
     *  @param userId                       用户id
     *  @param date                         require日期yyyy-MM-dd HH:mm:ss
     *  @param silentHeartRate              静息心率
     *  @param burnFatThreshold             燃烧脂肪阀值
     *  @param aerobicThreshold             有氧训练阀值
     *  @param limitThreshold               峰值训练阀值
     *  @param burnFatMinutes               燃烧脂肪时间
     *  @param aerobicMinutes               有氧训练时间
     *  @param limitMinutes                 峰值训练时间
     *  @param itemsStartTime               开始时间
     *  @param items                        数据[{从开始时间偏移分钟数,心率值},{}...{}]
     * ]
     */
    public func addEverydayHeartrates(withParam params: [NWHHeartrateAddParam], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        var dict = [[String: Any?]]()
        for param in params{
            var itemsStr = "["
            if let items = param.items{
                for (index, tuple) in items.enumerated() {
                    if index != 0{
                        itemsStr += ","
                    }
                    itemsStr += "{\(tuple[0]),\(tuple[1])}"
                }
            }
            itemsStr += "]"
            if let date = param.date, let itemsStartTime = param.itemsStartTime{
                let subDict: [String: Any?] = [
                    "deviceId": param.deviceId,
                    "userId": param.userId,
                    "date": date.formatString(with: "yyyy-MM-dd HH:mm:ss"),
                    "silentHeartRate": "\(param.silentHeartRate)",
                    "burnFatThreshold": "\(param.burnFatThreshold)",
                    "aerobicThreshold": "\(param.aerobicThreshold)",
                    "limitThreshold": "\(param.limitThreshold)",
                    "burnFatMinutes": "\(param.burnFatMinutes)",
                    "aerobicMinutes": "\(param.aerobicMinutes)",
                    "limitMinutes": "\(param.limitMinutes)",
                    "itemsStartTime": itemsStartTime.formatString(with: "yyyy-MM-dd HH:mm:ss"),
                    "items": itemsStr
                ]
                dict.append(subDict)
            }
        }
        Session.session(withAction: Actions.everydayHeartratesAdd, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-下拉心率
    /*
     *  @params deviceId                    require 设备id
     *  @params userId                      option  用户id
     *  @params fromDate                    option  恢复开始日期yyyy-MM-dd
     *  @params endDate                     option  恢复结束日期yyyy-MM-dd
     */
    public func pullEverydayHeartrates(withParam param: NWHEverydayDataPullParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [String: Any]()
        if let deviceId = param.deviceId {
            dict["deviceId"] = deviceId
        }
        if let userId = param.userId {
            dict["userId"] = userId
        }
        if let fromDate = param.fromDate{
            dict["fromDate"] = fromDate
        }
        if let endDate = param.endDate {
            dict["endDate"] = endDate
        }
        Session.session(withAction: Actions.everydayHeartratesPull, withMethod: Method.get, withParam: dict, closure: closure)
    }
    
    //MARK:-上传步数
    /*
     * [
     *  @param deviceId                     require 设备id
     *  @param userId                       用户id
     *  @param date                         require日期yyyy-MM-dd HH:mm:ss
     *  @param steps                        总步数
     *  @param calories                     总卡路里
     *  @param distances                    总距离
     *  @param totalSeconds                 总时长
     *  @param items                        数据[{偏移,消耗卡路里,步数,距离米},{}...{}]
     * ]
     */
    public func addEverydayStep(withParam params: [NWHStepAddParam], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [[String: Any]]()
        for param in params {
            var itemsStr = "["
            if let items = param.items {
                for (index, tuple) in items.enumerated() {
                    if index != 0{
                        itemsStr += ","
                    }
                    itemsStr += "{\(tuple[0]),\(tuple[1]),\(tuple[2]),\(tuple[3])}"
                }
            }
            itemsStr += "]"
            
            if let date = param.date{
                let subDict: [String: Any] = [
                    "deviceId": param.deviceId!,
                    "userId": param.userId!,
                    "date": date.formatString(with: "yyyy-MM-dd HH:mm:ss"),
                    "steps": "\(param.steps)",
                    "calories": "\(param.calories)",
                    "distances": "\(param.distances)",
                    "totalSeconds": "\(param.totalSeconds)",
                    "items": itemsStr
                ]
                dict.append(subDict)
            }
        }
        Session.session(withAction: Actions.everydayStepAdd, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-下拉步数
    /*
     *  @params deviceId                    设备id
     *  @params userId                      用户id
     *  @params fromDate                    恢复开始日期yyyy-MM-dd
     *  @params endDate                     恢复结束日期yyyy-MM-dd
     */
    public func pullEverydayStep(withParam param: NWHEverydayDataPullParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [String: Any]()
        if let deviceId = param.deviceId {
            dict["deviceId"] = deviceId
        }
        if let userId = param.userId {
            dict["userId"] = userId
        }
        if let fromDate = param.fromDate{
            dict["fromDate"] = fromDate
        }
        if let endDate = param.endDate {
            dict["endDate"] = endDate
        }
        Session.session(withAction: Actions.everydayStepPull, withMethod: Method.get, withParam: dict, closure: closure)
    }
    
    //MARK:-上传睡眠
    /*
     * [
     *  @param deviceId                     require 设备id
     *  @param userId                       用户id
     *  @param date                         require日期yyyy-MM-dd HH:mm:ss
     *  @param endedDatetime                睡眠结束时间yyyy-MM-dd HH:mm:ss
     *  @param totalMinutes                 总时长
     *  @param lightSleepMinutes            浅水时长
     *  @param deepSleepMinutes             深睡时长
     *  @param awakeSleepMinutes            清醒时长
     *  @param items                        数据[{偏移分钟数,睡眠类型},{}...{}]
     * ]
     */
    public func addEverydaySleep(withParam params: [NWHSleepAddParam], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [[String: Any]]()
        for param in params{
            var itemsStr = "["
            if let items = param.items {
                for (index, tuple) in items.enumerated() {
                    if index != 0{
                        itemsStr += ","
                    }
                    itemsStr += "{\(tuple[0]),\(tuple[1])}"
                }
            }
            itemsStr += "]"
            
            if let date = param.date, let endedDatetime = param.endedDatetime{
                let subDict: [String: Any] = [
                    "deviceId": param.deviceId!,
                    "userId": param.userId!,
                    "date": date.formatString(with: "yyyy-MM-dd HH:mm:ss"),
                    "endedDatetime": endedDatetime.formatString(with: "yyyy-MM-dd HH:mm:ss"),
                    "totalMinutes": "\(param.totalMinutes)",
                    "lightSleepMinutes": "\(param.lightSleepMinutes)",
                    "deepSleepMinutes": "\(param.deepSleepMinutes)",
                    "awakeSleepMinutes": "\(param.awakeSleepMinutes)",
                    "items": itemsStr
                ]
                dict.append(subDict)
            }
        }
        Session.session(withAction: Actions.everydaySleepAdd, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-下拉睡眠
    /*
     *  @params deviceId                    设备id
     *  @params userId                      用户id
     *  @params fromDate                    恢复开始日期yyyy-MM-dd
     *  @params endDate                     恢复结束日期yyyy-MM-dd
     */
    public func pullEverydaySleep(withParam param: NWHEverydayDataPullParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [String: Any]()
        if let deviceId = param.deviceId {
            dict["deviceId"] = deviceId
        }
        if let userId = param.userId {
            dict["userId"] = userId
        }
        if let fromDate = param.fromDate{
            dict["fromDate"] = fromDate
        }
        if let endDate = param.endDate {
            dict["endDate"] = endDate
        }
        Session.session(withAction: Actions.everydaySleepPull, withMethod: Method.get, withParam: dict, closure: closure)
    }
    
    //MARK:-上传训练
    /*
     * [
     *  @param deviceId                     require 设备id
     *  @param userId                       用户id
     *  @param date                         require日期yyyy-MM-dd HH:mm:ss(deprecated)
     *  @param startedAt                    require日期yyyy-MM-dd HH:mm:ss
     *  @param heartRateItemIntervalSeconds 心率间隔
     *  @param stepItemIntervalSeconds      步数间隔
     *  @param type                         运动类型
     *  @param durationSeconds              总时长
     *  @param calories                     总卡路里
     *  @param distances                    总距离
     *  @param averageHeartRate             平均心率
     *  @param maxHeartRate                 最大心率
     *  @param burnFatMinutes               燃烧脂肪时长
     *  @param aerobicMinutes               有氧训练时长
     *  @param limitMinutes                 峰值训练时长
     *  @param mapSource                    地图源NWHMapType
     *  @param steps                        步数数据[步数]
     *  @param heartRates                   心率数据[心率]
     *  @param gps                          gps数据[{longtitude,latitude,yyyy-MM-dd HH:mm:ss},{}...{}]
     * ]
     */
    public func addEverydayTraining(withParam params: [NWHTrainingAddParam], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [[String: Any]]()
        for param in params{
            var stepsStr = "["
            if let steps = param.steps{
                for (index, step) in steps.enumerated(){
                    if index != 0{
                        stepsStr += ","
                    }
                    stepsStr += "\(step)"
                }
            }
            stepsStr += "]"
            
            var heartRatesStr = "["
            if let heartRates = param.heartRates{
                for (index, heartrate) in heartRates.enumerated(){
                    if index != 0{
                        heartRatesStr += ","
                    }
                    heartRatesStr += "\(heartrate)"
                }
            }
            heartRatesStr += "]"
            
            var gpsStr = "["
            if let gps = param.gps{
                for (index, tuple) in gps.enumerated() {
                    if index != 0 {
                        gpsStr += ","
                    }
                    gpsStr += "{\(tuple[0]),\(tuple[1])," + (tuple[2] as! Date).formatString(with: "yyyy-MM-dd HH:mm:ss") + "}"
                }
            }
            gpsStr += "]"
            
            if let date = param.date, let startedAt = param.startedAt{
                let subDict: [String: Any] = [
                    "deviceId": param.deviceId!,
                    "userId": param.userId!,
                    "date": date.formatString(with: "yyyy-MM-dd HH:mm:ss"),
                    "startedAt": startedAt.formatString(with: "yyyy-MM-dd HH:mm:ss"),
                    "heartRateItemIntervalSeconds": param.heartRateItemIntervalSeconds,
                    "stepItemIntervalSeconds": param.stepItemIntervalSeconds,
                    "type": "\(param.type)",
                    "durationSeconds": "\(param.durationSeconds)",
                    "calories": "\(param.calories)",
                    "distances": "\(param.distances)",
                    "averageHeartRate": "\(param.averageHeartRate)",
                    "maxHeartRate": "\(param.maxHeartRate)",
                    "burnFatMinutes": "\(param.burnFatMinutes)",
                    "aerobicMinutes": "\(param.aerobicMinutes)",
                    "limitMinutes": "\(param.limitMinutes)",
                    "mapSource": param.mapSource,
                    "steps": stepsStr,
                    "heartRates": heartRatesStr,
                    "gps": gpsStr
                ]
                dict.append(subDict)
            }
        }
        Session.session(withAction: Actions.everydayTrainingAdd, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-下拉训练
    /*
     *  @params deviceId                    设备id
     *  @params userId                      用户id
     *  @params fromDate                    恢复开始日期yyyy-MM-dd
     *  @params endDate                     恢复结束日期yyyy-MM-dd
     */
    public func pullEverydayTraining(withParam param: NWHEverydayDataPullParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [String: Any]()
        if let deviceId = param.deviceId {
            dict["deviceId"] = deviceId
        }
        if let userId = param.userId {
            dict["userId"] = userId
        }
        if let fromDate = param.fromDate{
            dict["fromDate"] = fromDate
        }
        if let endDate = param.endDate {
            dict["endDate"] = endDate
        }
        Session.session(withAction: Actions.everydayTrainingPull, withMethod: Method.get, withParam: dict, closure: closure)
    }
}
