//
//  CDH+Alarm.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/8.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    //插入 alarm
    public func insertDeviceAlarm(withUserId userId: Int64? = nil, withAccessoryId accessoryId: String) -> DeviceAlarm?{
        
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //获取设备
        let device = selectDevice(withAccessoryId: accessoryId, byUserId: uid)

        //获取最大闹钟数
        guard let maxAlarmCount = device?.deviceFunctionSwitchSetting?.alarmOnCount else{
            return nil
        }
        
        let allAlarms = selectAllDeviceAlarms(withAccessoryId: accessoryId)
        
        //判断闹钟是否达到最大数
        guard allAlarms.count < Int(maxAlarmCount) else {
            return nil
        }
        
        var alarmId: Int16 = 0
        var deviceAlarm: DeviceAlarm?
        repeat{
            alarmId += 1
            deviceAlarm = selectDeviceAlarm(byUserId: uid, byAlarmId: alarmId, withAccessoryId: accessoryId)
        }while deviceAlarm != nil
        
        deviceAlarm = NSEntityDescription.insertNewObject(forEntityName: "DeviceAlarm", into: context) as? DeviceAlarm
        deviceAlarm?.alarmId = alarmId
        
        if let a = deviceAlarm {
            device?.addToDeviceAlarmList(a)
            guard commit() else {
                return a
            }
        }
        return nil
    }
    
    //获取 alarm
    public func selectDeviceAlarm(byUserId userId: Int64? = nil, byAlarmId alarmId: Int16, withAccessoryId accessoryId: Int64) -> DeviceAlarm? {
        
        //判断userId
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //查找
        let request: NSFetchRequest<DeviceAlarm> = DeviceAlarm.fetchRequest()
        let predicate = NSPredicate(format: "alarmId = \(alarmId) AND device.user.userId = \(uid) AND device.accessory = \(accessoryId)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            return resultList.first
        }catch let error{
            fatalError("<Core Data> fetch error: \(error)")
        }
        return nil
    }
    
    //获取所有 alarm
    public func selectAllDeviceAlarms(byUserId userId: Int64? = nil, withAccessoryId accessoryId: Int64) -> [DeviceAlarm]{
        
        //判断userId
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //查找
        let request: NSFetchRequest<DeviceAlarm> = DeviceAlarm.fetchRequest()
        let predicate = NSPredicate(format: "device.user.userId = \(uid) AND device.accessory = \(accessoryId)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch error: \(error)")
        }
        return []
    }
    
    //删除 alarm
    public func deleteDeviceAlarm(byAlarmId alarmId: Int16, byUserId userId: Int64? = nil, withAccessoryId accessoryId: Int64){
        
        guard let deviceAlarm = selectDeviceAlarm(byUserId: userId, byAlarmId: alarmId, withAccessoryId: accessoryId) else {
            return
        }
        context.delete(deviceAlarm)
        guard commit() else{
            return
        }
    }
}
