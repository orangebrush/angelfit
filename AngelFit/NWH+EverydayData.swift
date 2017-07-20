//
//  NWH+EverydayData.swift
//  AngelFit
//
//  Created by YiGan on 20/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//1 stepitems96 2date 3deviceid

import Foundation
//地图类型
public enum NWHMapType: String {
    case apple = "A", baidu = "B", amap = "D"
}
public class NWHEverydayData {
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NWHDevice()
    public class func share() -> NWHDevice{
        return __once
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
    public func addEverydayHeartrates(withParam param: [[String: Any]], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.everydayHeartratesAdd, withMethod: Method.post, withParam: param, closure: closure)
    }
    
    //MARK:-下拉心率
    /*
     *  @params deviceId                    设备id
     *  @params userId                      用户id
     *  @params fromDate                    恢复开始日期yyyy-MM-dd
     *  @params endDate                     恢复结束日期yyyy-MM-dd
     */
    public func pullEverydayHeartrates(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.everydayHeartratesPull, withMethod: Method.get, withParam: param, closure: closure)
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
     *  @param items                        数据[{步数},{}...{}]
     * ]
     */
    public func addEverydayStep(withParam param: [[String: Any]], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.everydayStepAdd, withMethod: Method.post, withParam: param, closure: closure)
    }
    
    //MARK:-下拉步数
    /*
     *  @params deviceId                    设备id
     *  @params userId                      用户id
     *  @params fromDate                    恢复开始日期yyyy-MM-dd
     *  @params endDate                     恢复结束日期yyyy-MM-dd
     */
    public func pullEverydayStep(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.everydayStepPull, withMethod: Method.get, withParam: param, closure: closure)
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
    public func addEverydaySleep(withParam param: [[String: Any]], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.everydaySleepAdd, withMethod: Method.post, withParam: param, closure: closure)
    }
    
    //MARK:-下拉睡眠
    /*
     *  @params deviceId                    设备id
     *  @params userId                      用户id
     *  @params fromDate                    恢复开始日期yyyy-MM-dd
     *  @params endDate                     恢复结束日期yyyy-MM-dd
     */
    public func pullEverydaySleep(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.everydaySleepPull, withMethod: Method.get, withParam: param, closure: closure)
    }
    
    //MARK:-上传训练
    /*
     * [
     *  @param deviceId                     require 设备id
     *  @param userId                       用户id
     *  @param date                         require日期yyyy-MM-dd HH:mm:ss
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
    public func addEverydayTraining(withParam param: [[String: Any]], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.everydayTrainingAdd, withMethod: Method.post, withParam: param, closure: closure)
    }
    
    //MARK:-下拉训练
    /*
     *  @params deviceId                    设备id
     *  @params userId                      用户id
     *  @params fromDate                    恢复开始日期yyyy-MM-dd
     *  @params endDate                     恢复结束日期yyyy-MM-dd
     */
    public func pullEverydayTraining(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.everydayTrainingPull, withMethod: Method.get, withParam: param, closure: closure)
    }
}
