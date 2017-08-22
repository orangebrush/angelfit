//
//  CoreDataConfigure.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/8.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation

//MARK:- 设备类型
public let kCDHDeviceTypeNone: Int16            = 0x01 << 0                     //无
public let kCDHDeviceTypeBand: Int16            = 0x01 << 1                     //手环
public let kCDHDeviceTypeWatch: Int16           = 0x01 << 2                     //手表
public let kCDHDeviceTypeScale: Int16           = 0x01 << 3
public let kCDHDeviceTypeJumprope: Int16        = 0x01 << 4
public let kCDHDeviceTypeDumbbell: Int16        = 0x01 << 5
public let kCDHDeviceTypeBikeComputer: Int16    = 0x01 << 6
public let kCDHDeviceTypeOther: Int16           = 0x01 << 7                     //其他


//MARK:- 设备电量
public let kCDHDeviceBatteryStatusNormal: Int16 = 0x01 << 0                     //正常
public let kCDHDeviceBatteryStatusCharging: Int16 = 0x01 << 1
public let kCDHDeviceBatteryStatusLowPower: Int16 = 0x01 << 2                   //低电量

//MARK:- 哈博士反馈
public let kCDHDoctorHaSuggestionFeedbackTypeUnLike: Int16      = 0x01 << 0     //喜欢
public let kCDHDoctorHaSuggestionFeedbackTypelike: Int16        = 0x01 << 1     //不喜欢

//MARK:- 活动数据地图类型
public let kCDHEachTrainingDataMapSourceNone: Int16         = 0x01 << 0         //无
public let kCDHEachTrainingDataMapSourceBaiduMap: Int16     = 0x01 << 1         //百度地图
public let kCDHEachTrainingDataMapSourceAutonaviMap: Int16  = 0x01 << 2         //高德地图
public let kCDHEachTrainingDataMapSourceGoogleMap: Int16    = 0x01 << 3         //谷歌地图
public let kCDHEachTrainingDataMapSourceAppleMap: Int16     = 0x01 << 4         //苹果地图
public let kCDHEachTrainingDataMapSourceShougouMap: Int16   = 0x01 << 5         //搜狗地图
public let kCDHEachTrainingDataMapSourceTencentMap: Int16   = 0x01 << 6         //腾讯地图

//MARK:- 身心状态类型
public let kCDHMindBodyStateAmazing: Int16      = 0x01 << 0                     //太棒了
public let kCDHMindBodyStatePumpedUp: Int16     = 0x01 << 1                     //充满活力
public let kCDHMindBodyStateEnegized: Int16     = 0x01 << 2                     //精力充沛
public let kCDHMindBodyStateGood: Int16         = 0x01 << 3                     //感觉不错
public let kCDHMindBodyStateMeh: Int16          = 0x01 << 4                     //感觉一般
public let kCDHMindBodyStateDragging: Int16     = 0x01 << 5                     //有些劳累
public let kCDHMindBodyStateExhausted: Int16    = 0x01 << 6                     //疲惫不堪
public let kCDHMindBodyStateTotallyDone: Int16  = 0x01 << 7                     //精疲力尽

//MARK:- 身心状态类型
public enum CDHMindBodyState: Int16{
    case amazing        = 1                                                     //太棒了
    case pumpedUp       = 2                                                     //充满活力
    case energized      = 4                                                     //精力充沛
    case good           = 8                                                     //感觉不错
    case meh            = 16                                                    //感觉一般
    case dragging       = 32                                                    //有些劳累
    case exhausted      = 64                                                    //疲惫不堪
    case totallyDone    = 128                                                   //精疲力尽
}

//MARK:- 睡眠状态
public let kCDHSleepStateNone: Int16        = 0x01 << 0                         //无
public let kCDHSleepStateAwake: Int16       = 0x01 << 1                         //清醒
public let kCDHSleepStateDeepSleep: Int16   = 0x01 << 2                         //深睡眠
public let kCDHSleepStateLightSleep: Int16  = 0x01 << 3                         //浅睡眠
public let kCDHSleepStateRemSleep: Int16    = 0x01 << 4                         //眼动睡眠

//MARK:- 语言类型
public let kCDHUnitSettingLangCh: Int16 = 0x01 << 0                             //中文
public let kCDHUnitSettingLangEn: Int16 = 0x01 << 1                             //英文

//MARK:- 星期开始日
public let kCDHUnitSettingWeekdayMonday: Int16 = 0x01 << 0                      //星期一
public let kCDHUnitSettingWeekdaySunday: Int16 = 0x01 << 1                      //星期天
public let kCDHUnitSettingWeekdaySaturday: Int16 = 0x01 << 2                    //星期六

//MARK:- 活动详情类别
public let kCDHUserActivityTypeEverydaySport: Int16         = 0x01 << 0         //每日活动
public let kCDHUserActivityTypeEverydaySleep: Int16         = 0x01 << 1         //每日睡眠
public let kCDHUserActivityTypeEverydayRestingHr: Int16     = 0x01 << 2         //每日心率
public let kCDHUserActivityTypeTrainingData: Int16          = 0x01 << 3         //活动数据
public let kCDHUserActivityTypeWeight: Int16                = 0x01 << 4         //体重
public let kCDHUserActivityTypeMood: Int16                  = 0x01 << 5         //心情
public let kCDHUserActivityTypeBloodPressure: Int16         = 0x01 << 6         //血压

//MARK:- 活动详情表情"UNLIKE",”LIKE”, “LOVE”, “HAPPY”, “SAD”, “ANGRY”
public let kCDHUserActivityEmotionTypeUnlike: Int16 = 0x01 << 0                 //不喜欢
public let kCDHUserActivityEmotionTypeLike: Int16 = 0x01 << 1                   //喜欢
public let kCDHUserActivityEmotionTypeLove: Int16 = 0x01 << 2                   //爱心
public let kCDHUserActivityEmotionTypeHappy: Int16 = 0x01 << 3                  //高兴
public let kCDHUserActivityEmotionTypeSad: Int16 = 0x01 << 4                    //不开心
public let kCDHUserActivityEmotionTypeAngry: Int16 = 0x01 << 5                  //愤怒

//MARK:- 获取体重方式
public enum CDHRange {
    case day                                                                    //天
    case week                                                                   //周
    case month                                                                  //月
    case year                                                                   //年
    case all                                                                    //全部
}

