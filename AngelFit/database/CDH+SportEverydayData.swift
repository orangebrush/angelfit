//
//  CDH+SportEverydayData.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/9.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
//MARK:- SportEverydayData
extension CoreDataHandler{
    
    //插入单日血压数据
    public func insertSportEverydayData(withAccessoryId accessoryId: String, UserId userId: String? = nil, withDate date: Date = Date()) -> SportEverydayData? {
        
        //判断是否已存在当日数据
        var sportEverydayData = selectSportEverydayData(withAccessoryId: accessoryId, byUserId: userId, withDate: date)
        
        if let oldResult = sportEverydayData {
            return oldResult
        }
        
        //判断userId
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //一并创建userActivity
        guard let userActivity = insertUserActivity(withActivityType: kCDHUserActivityTypeEverydaySport) else{
            return nil
        }
        
        //创建插入对象
        sportEverydayData = NSEntityDescription.insertNewObject(forEntityName: "SportEverydayData", into: context) as? SportEverydayData
        guard let newResult = sportEverydayData  else {
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
        device.addToSportEverydayDataList(newResult)
        guard commit() else {
            return nil
        }
        
        return newResult
    }
    
    //根据日期获取SportEverydayData
    public func selectSportEverydayData(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date = Date()) -> SportEverydayData?{
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<SportEverydayData> = SportEverydayData.fetchRequest()
        let predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\" AND date = %@", translate(date) as CVarArg)
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList.first
        }catch let error{
            fatalError("<Core Data> fetch sport everyday data error: \(error)")
        }
        return nil
    }
    
    //根据日期范围获取SportEverydayData
    public func selectSportEverydayDataList(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date = Date(), withDayOffset dayOffset: Int = 0) -> [SportEverydayData]{
        
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<SportEverydayData> = SportEverydayData.fetchRequest()
        let startDate = dayOffset >= 0 ? translate(date) : translate(date, withDayOffset: dayOffset)  //as NSDate
        let endDate = dayOffset >= 0 ? translate(date, withDayOffset: dayOffset) : translate(date)    //as NSDate
        let predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\"  AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch sport everyday data with dayoffset error: \(error)")
        }
        return []
    }
    
    //根据日期范围获取SportEverydayData 日周月年
    public func selectSportEverydayDataList(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date = Date(), withCDHRange cdhRange: CDHRange) -> [SportEverydayData]{
        
        guard let uid = userId else {
            return []
        }
        let request: NSFetchRequest<SportEverydayData> = SportEverydayData.fetchRequest()
        
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
            fatalError("<Core Data> fetch sport everyday data with range error: \(error)")
        }
        return []
    }
    
    //MARK:- 根据日期删除对应userId运动数据
    public func deleteSportEverydayData(withAccessoryId accessoryId: String, byUserId userId: String, withDate date: Date = Date()){
        guard let sportEverydayData = selectSportEverydayData(withAccessoryId: accessoryId, byUserId: userId, withDate: date) else {
            return
        }
        
        context.delete(sportEverydayData)
        guard commit() else {
            return
        }
    }
    
    //MARK:- items操作
    public func createSportEverydayDataItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16) -> SportEverydayDataItem?{
        //判断item是否存在
        var sportEverydayDataItem = selectSportEverydayDataItem(withAccessoryId: accessoryId, byUserId: userId, withDate: date, withItemId: itemId)
        if let oldItem = sportEverydayDataItem{
            return oldItem
        }
        sportEverydayDataItem = NSEntityDescription.insertNewObject(forEntityName: "SportEverydayDataItem", into: context) as? SportEverydayDataItem
        guard let newItem = sportEverydayDataItem else{
            return nil
        }
        
        newItem.id = itemId
        
        //插入BloodPressureEverydayData item列表
        guard let sportEverydayData = selectSportEverydayData(withAccessoryId: accessoryId, byUserId: userId, withDate: date) else {
            return nil
        }
        
        sportEverydayData.addToSportEverydayDataItemList(newItem)
        
        guard commit() else {
            return nil
        }
        return newItem
    }
    
    public func selectSportEverydayDataItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16) -> SportEverydayDataItem?{
        guard let uid = userId else {
            return nil
        }
        
        let request: NSFetchRequest<SportEverydayDataItem> = SportEverydayDataItem.fetchRequest()
        let predicate = NSPredicate(format: "sportEverydayData.date = \(date) AND sportEverydayData.device.accessoryId = \"\(accessoryId)\"")
        request.predicate = predicate
        
        do {
            let resultList = try context.fetch(request)
            return resultList.first
        } catch let error {
            fatalError("<Core Data> fetch sport everyday data item error: \(error)")
        }
        return nil
    }
}
