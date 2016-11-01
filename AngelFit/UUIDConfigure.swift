//
//  GodUUID.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/10/31.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import UIKit
import CoreBluetooth
struct MainUUID {
    //MARK:- 服务特征
    static let service = CBUUID(string: "00000af0-0000-1000-8000-00805f9b34fb")
    //MARK:- 写
    static let write =   CBUUID(string: "00000af6-0000-1000-8000-00805f9b34fb")
    //MARK:- 读
    static let read = CBUUID(string: "00000af7-0000-1000-8000-00805f9b34fb")
    //MARK:- 大数据写
    static let bigWrite = CBUUID(string: "00000af1-0000-1000-8000-00805f9b34fb")
    //MARK:- 大数据读
    static let bigRead = CBUUID(string: "00000af2-0000-1000-8000-00805f9b34fb")
}
