//
//  CDH+HeartRateEverydayData.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/9.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
//MARK:- HeartRateEverydayData
extension CoreDataHandler{
    
    //插入单日心率数据
    public func insertHeartRateEverydayData(withAccessoryId accessoryId: String, byUserId userId: String? = nil, withDate date: Date = Date()) -> HeartRateEverydayData? {
        
        //判断是否已存在当日数据
        var heartRateEverydayData = selectHeartRateEverydayData(withAccessoryId: accessoryId, byUserId: userId, withDate: date)
        if let oldResult = heartRateEverydayData {
            return oldResult
        }
        
        //判断userId
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //一并创建userActivity
        guard let userActivity = insertUserActivity(withActivityType: kCDHUserActivityTypeEverydayRestingHr, withAccessoryId: accessoryId) else{
            return nil
        }
        
        //创建插入对象
        heartRateEverydayData = NSEntityDescription.insertNewObject(forEntityName: "HeartRateEverydayData", into: context) as? HeartRateEverydayData
        guard let newResult = heartRateEverydayData  else {
            return nil
        }
        
        newResult.date = date as NSDate
        newResult.objectId = userActivity.objectId
        
//        //获取需插入的用户
//        guard let user = selectUser(withUserId: uid) else{
//            return nil
//        }
        
        //获取设备
        guard let device = selectDevice(withAccessoryId: accessoryId, byUserId: userId) else {
            return nil
        }
        device.addToHeartRateEverydayDataList(newResult)
        
        guard commit() else {
            return nil
        }
        
        return newResult
    }
    
    //根据日期获取HeartRateEverydayData
    public func selectHeartRateEverydayData(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date = Date()) -> HeartRateEverydayData?{
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<HeartRateEverydayData> = HeartRateEverydayData.fetchRequest()
        let predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\" AND date = %@", translate(date) as CVarArg)
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList.first
        }catch let error{
            fatalError("<Core Data> fetch heart rate everyday data error: \(error)")
        }
        return nil
    }
    
    //根据日期范围获取HeartRateEverydayData
    public func selectHeartRateEverydayDataList(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date = Date(), withDayOffset dayOffset: Int = 0) -> [HeartRateEverydayData]{
        
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<HeartRateEverydayData> = HeartRateEverydayData.fetchRequest()
        let startDate = dayOffset >= 0 ? translate(date) : translate(date, withDayOffset: dayOffset)  //as NSDate
        let endDate = dayOffset >= 0 ? translate(date, withDayOffset: dayOffset) : translate(date)    //as NSDate
        let predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch heart rate everyday data with dayoffset error: \(error)")
        }
        return []
    }
    
    //根据日期范围获取HeartRateEverydayData 日周月年
    public func selectHeartRateEverydayDataList(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date = Date(), withCDHRange cdhRange: CDHRange) -> [HeartRateEverydayData]{
        
        guard let uid = userId else {
            return []
        }
        let request: NSFetchRequest<HeartRateEverydayData> = HeartRateEverydayData.fetchRequest()
        
        //根据条件创建查询
        var predicate: NSPredicate?
        switch cdhRange {
        case .day:
            let startDate = translate(date)
            let endDate = translate(date)
            predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .week:
            let weekday = calendar.component(.weekday, from: date)
            let startDate = translate(date, withDayOffset: -weekday)
            let endDate = translate(date, withDayOffset: 7 - weekday)
            predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .month:
            let day = calendar.component(.day, from: date)
            if let dayRange = calendar.range(of: .day, in: .month, for: date){
                let daysOfMonth = Int(dayRange.count)
                
                let startDate = translate(date, withDayOffset: -day)
                let endDate = translate(date, withDayOffset: daysOfMonth - day)
                predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
            }else{
                return []
            }
        case .year:
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.month = 1
            components.day = 1
            //创建开始日期
            if let date1 = calendar.date(from: components){
                let startDate = translate(date1.GMT())
                if let year = components.year{
                    components.year = year + 1
                    //创建结束日期
                    if let date2 = calendar.date(from: components){
                        let endDate = translate(date2.GMT(), withDayOffset: -1)
                        predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
                    }else{
                        return []
                    }
                }else{
                    return []
                }
            }else{
                return []
            }
        case .all:
            predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\"")
        }
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch heart rate everyday data with range error: \(error)")
        }
        return []
    }
    
    //MARK:- 根据日期删除对应userId心率数据
    public func deleteHeartRateEverydayData(withAccessoryId accessoryId: String, byUserId userId: String, withDate date: Date = Date()){
        guard let heartRateEverydayData = selectHeartRateEverydayData(withAccessoryId: accessoryId, byUserId: userId, withDate: date) else {
            return
        }
        
        context.delete(heartRateEverydayData)
        guard commit() else {
            return
        }
    }
    
    //MARK:- items操作
    public func createHeartRateEverydayDataItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16) -> HeartRateEverydayDataItem?{
        //判断item是否存在
        var heartRateEverydayDataItem = selectHeartRateEverydayDataItem(withAccessoryId: accessoryId, byUserId: userId, withDate: date, withItemId: itemId)
        if let oldItem = heartRateEverydayDataItem{
            return oldItem
        }
        heartRateEverydayDataItem = NSEntityDescription.insertNewObject(forEntityName: "HeartRateEverydayDataItem", into: context) as? HeartRateEverydayDataItem
        guard let newItem = heartRateEverydayDataItem else{
            return nil
        }
        
        newItem.id = itemId
        
        //插入BloodPressureEverydayData item列表
        guard let heartRateEverydayData = selectHeartRateEverydayData(withAccessoryId: accessoryId, byUserId: userId, withDate: date) else {
            return nil
        }
        
        heartRateEverydayData.addToHeartRateEverydayItemList(newItem)
        guard commit() else {
            return nil
        }
        return newItem
    }
    
    public func selectHeartRateEverydayDataItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16) -> HeartRateEverydayDataItem?{
        guard let uid = userId else {
            return nil
        }
        
        let request: NSFetchRequest<HeartRateEverydayDataItem> = HeartRateEverydayDataItem.fetchRequest()
        let predicate = NSPredicate(format: "heartRateEverydayData.date = %@ AND heartRateEverydayData.device.accessoryId = \"\(accessoryId)\"", translate(date) as CVarArg)
        request.predicate = predicate
        
        do {
            let resultList = try context.fetch(request)
            return resultList.first
        } catch let error {
            fatalError("<Core Data> fetch heart rate everyday data item error: \(error)")
        }
        return nil
    }
}
