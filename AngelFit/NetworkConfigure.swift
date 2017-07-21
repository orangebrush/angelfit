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
public let kNWHDeviceBatteryTypeLithiumCell: Int    = 0 //锂电池
public let kNWHDeviceBatteryTypeButtonCell: Int     = 1 //纽扣电池

//地图类型
public let kNWHEverydayDataMapTypeApple = "A"   //苹果地图
public let kNWHEverydayDataMapTypeBaidu = "B"   //百度地图
public let kNWHEverydayDataMapTypeAMap = "D"    //高德地图
