//
//  NWH+Device.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
//设备的类型
public enum NWHDeviceType: Int{
    case none = 0, band, watch, scale, jumprope, dumbball, bikeComputer, other
}
//电池类型
public enum NWHDeviceBatteryType: Int {
    case lithiumCell = 0, buttonCell
}
public class NWHDevice{
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NWHDevice()
    public class func share() -> NWHDevice{
        return __once
    }
    
    //MARK:-新增设备
    /*
     * @param id                require 由设备唯一id,由deviceType,deviceId与uuid组成
     * @param macAddress        设备物理地址
     * @param uuid              设备uuid
     * @param name              设备名
     * @param showName          显示名
     * @param type              设备类型 NWHDeviceType
     * @param batteryType       电池类型 NWHDeviceBatteryType
     * @param totalUsedMinutes  总共使用分钟数
     */
    public func add(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.deviceAdd, withMethod: Method.post, withParam: param, closure: closure)
    }
    
    //MARK:-设备更新
    /*
     * params同新增设备
     */
    public func update(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.deviceUpdate, withMethod: Method.post, withParam: param, closure: closure)
    }
}
