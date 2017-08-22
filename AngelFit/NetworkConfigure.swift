//
//  NetworkConfigure.swift
//  AngelFit
//
//  Created by YiGan on 21/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
//设备的类型
public let kNWHDeviceTypeNone: Int          = 0 //无
public let kNWHDeviceTypeBand: Int          = 1 //手环
public let kNWHDeviceTypeWatch: Int         = 2 //手表
public let kNWHDeviceTypeScale: Int         = 3 //
public let kNWHDeviceTypeJumprope: Int      = 4 //跳绳器
public let kNWHDeviceTypeDumbball: Int      = 5 //哑铃
public let kNWHDeviceTypeBikeComputer: Int  = 6 //动感单车
public let kNWHDeviceTypeOther: Int         = 7 //其他

//电池类型
public let kNWHDeviceBatteryTypeLithiumCell: String    = "L" //锂电池
public let kNWHDeviceBatteryTypeButtonCell: String     = "B" //纽扣电池

//地图类型
public let kNWHEverydayDataMapTypeApple = "A"   //苹果地图
public let kNWHEverydayDataMapTypeBaidu = "B"   //百度地图
public let kNWHEverydayDataMapTypeAMap  = "D"   //高德地图

//设备错误类型
public let kNWHDeviceErrorTypeBinding       = "B"   //绑定错误
public let kNWHDeviceErrorTypeConnect       = "C"   //连接错误
public let kNWHDeviceErrorTypeUpdate        = "U"   //升级错误
public let kNWHDeviceErrorTypeFunclog       = "D"   //函数日志错误

//设备状态
public let kNWHDeviceBatteryStatusNormal    = "N"   //正常状态
public let kNWHDeviceBatteryStatusCharging  = "O"   //充电中
public let kNWHDeviceBatteryStatusCharged   = "C"   //充电完成
public let kNWHDeviceBatteryStatusLow       = "L"   //低电量

//设备交互功能
public let kNWHDeviceMsgNone                = 0     //无此功能
public let kNWHDeviceMsgOpen                = 1     //开启
public let kNWHDeviceMsgClose               = 2     //关闭

//运动类型
public let kNWHTraningType_BX               = 0     //步行
public let kNWHTraningType_PB               = 1     //跑步
public let kNWHTraningType_QX               = 2     //骑行
public let kNWHTraningType_TB               = 3     //徒步
public let kNWHTraningType_YY               = 4     //游泳
public let kNWHTraningType_PS               = 5     //爬山
public let kNWHTraningType_YMQ              = 6     //羽毛球
public let kNWHTraningType_QT               = 7     //其他
public let kNWHTraningType_JS               = 8     //健身
public let kNWHTraningType_DGDC             = 9     //动感单车
public let kNWHTraningType_TYQ              = 10    //椭圆球
public let kNWHTraningType_PBJ              = 11    //跑步机
public let kNWHTraningType_YWQZ             = 12    //仰卧起坐
public let kNWHTraningType_FWC              = 13    //俯卧撑
public let kNWHTraningType_YL               = 14    //哑铃
public let kNWHTraningType_JZ               = 15    //举重
public let kNWHTraningType_JSC              = 16    //健身操
public let kNWHTraningType_YJ               = 17    //瑜伽
public let kNWHTraningType_TS               = 18    //跳绳
public let kNWHTraningType_PPQ              = 19    //乒乓球
public let kNWHTraningType_LQ               = 20    //篮球
public let kNWHTraningType_ZQ               = 21    //足球
public let kNWHTraningType_PQ               = 22    //排球
public let kNWHTraningType_WQ               = 23    //网球
public let kNWHTraningType_GEF              = 24    //高尔夫
public let kNWHTraningType_BQ               = 25    //棒球
public let kNWHTraningType_HX               = 26    //滑雪
public let kNWHTraningType_LH               = 27    //轮滑
public let kNWHTraningType_TW               = 28    //跳舞
public let kNWHTraningType_BL               = 29    //保留
