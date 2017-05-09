//
//  CDH_Device.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/6.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    
    //MARK:- 插入设备
    public func insertDevice(withAccessoryId accessoryId: Int64, byUserId userId: Int64? = nil) -> Device?{
        
        //判断userId
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        var device = selectDevice(withAccessoryId: accessoryId, byUserId: userId)
        if device == nil {
            device = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context) as? Device
            
            device?.accessoryId = accessoryId
            
            //添加关系表... ontToOne
            device?.deviceAntiLostSetting = NSEntityDescription.insertNewObject(forEntityName: "DeviceAntiLostSetting", into: context) as? DeviceAntiLostSetting
            device?.deviceFunction = NSEntityDescription.insertNewObject(forEntityName: "DeviceFunction", into: context) as? DeviceFunction
            device?.deviceFunctionAlarm = NSEntityDescription.insertNewObject(forEntityName: "DeviceFunctionAlarm", into: context) as? DeviceFunctionAlarm
            device?.deviceFunctionSportItem = NSEntityDescription.insertNewObject(forEntityName: "DeviceFunctionSportItem", into: context) as? DeviceFunctionSportItem
            device?.deviceFunctionSwitchSetting = NSEntityDescription.insertNewObject(forEntityName: "DeviceFunctionSwitchSetting", into: context) as? DeviceFunctionSwitchSetting
            device?.deviceFunctionMsgItem = NSEntityDescription.insertNewObject(forEntityName: "DeviceFunctionMsgItem", into: context) as? DeviceFunctionMsgItem
            device?.deviceHeartRateMonitorSetting = NSEntityDescription.insertNewObject(forEntityName: "DeviceHeartRateMonitorSetting", into: context) as? DeviceHeartRateMonitorSetting
            device?.deviceLongSitSetting = NSEntityDescription.insertNewObject(forEntityName: "DeviceLongSitSetting", into: context) as? DeviceLongSitSetting
            device?.deviceMsgNotifySwitch = NSEntityDescription.insertNewObject(forEntityName: "DeviceMsgNotifySwitch", into: context) as? DeviceMsgNotifySwitch
            device?.deviceSportShortcut = NSEntityDescription.insertNewObject(forEntityName: "DeviceSportShortcut", into: context) as? DeviceSportShortcut
            
            //添加device进user
            let user = selectUser(withUserId: id)
            if let d = device{
                user?.addToDeviceList(d)
                
                guard commit() else {
                    return nil
                }
                return d
            }
            return nil
        }
        return device
    }
    
    //MARK:- 根据userId accessoryId获取设备
    public func selectDevice(withAccessoryId accessoryId: Int64, byUserId userId: Int64? = nil) -> Device?{
        
        //判断userId
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //查找
        let request: NSFetchRequest<Device> = Device.fetchRequest()
        let predicate = NSPredicate(format: "user.userId = \(id) AND accessory = \(accessoryId)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            if resultList.isEmpty {
                return nil
            }else{
                return resultList.first
            }
        }catch let error{
            fatalError("<Core Data> fetch error: \(error)")
            return nil
        }
    }
    
    //MARK:- 获取所有设备
    public func selectAllDevice(byUserId userId: Int64? = nil) -> [Device]{
        
        //判断userId
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //查找
        let request: NSFetchRequest<Device> = Device.fetchRequest()
        let predicate = NSPredicate(format: "user.userId = \(id)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch error: \(error)")
            return []
        }
    }
    
    //MARK:- 获取当前设备
    public func selectCurrentDevice(byUserId userId: Int64? = nil) -> Device?{
        let devices = selectAllDevice(byUserId: userId)
        return devices.last
    }
    
    //MARK:- 删除设备
    public func deleteDevice(withAccessoryId accessoryId: Int64, byUserId userId: Int64? = nil){
        
        //判断userId
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return
        }
        
        delete(Device.self, byConditionFormat: "user.userId = \(id) AND accessoryId = \(accessoryId)")
        guard commit() else {
            return
        }
    }
}
