//
//  CDH+BloodPressureEverydayData.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/8.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
//MARK:- BloodPressureEverydayData
extension CoreDataHandler{
    
    //插入单日血压数据
    public func insertBloodPressureEverydayData(byUserId userId: Int64? = nil, withDate date: Date = Date()) -> BloodPressureEverydayData? {
        
        //判断是否已存在当日数据
        var bloodPressureEverydayData = selectBloodPressureEverydayData(byUserId: userId, withDate: date)
        if let oldResult = bloodPressureEverydayData {
            return oldResult
        }
        
        //判断userId
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //一并创建userActivity
        guard let userActivity = insertUserActivity(withActivityType: kCDHUserActivityTypeBloodPressure) else{
            return nil
        }
        
        //创建插入对象
        bloodPressureEverydayData = NSEntityDescription.insertNewObject(forEntityName: "BloodPressureEverydayData", into: context) as? BloodPressureEverydayData
        guard let newResult = bloodPressureEverydayData  else {
            return nil
        }
        
        newResult.date = date as NSDate
        newResult.objectId = userActivity.objectId
        
        //获取需插入的用户
        guard let user = selectUser(withUserId: uid) else{
            return nil
        }
        user.addToBloodPressureEverydayDataList(newResult)
        
        guard commit() else {
            return nil
        }
        
        return newResult
    }
    
    //根据日期获取BloodPressureEverydayData
    public func selectBloodPressureEverydayData(byUserId userId: Int64?, withDate date: Date = Date()) -> BloodPressureEverydayData?{
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<BloodPressureEverydayData> = BloodPressureEverydayData.fetchRequest()
        let predicate = NSPredicate(format: "user.userId = \(uid) AND date = \(date)")
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList.first
        }catch let error{
            fatalError("<Core Data> fetch blood pressure everyday data error: \(error)")
        }
        return nil
    }
    
    //根据日期范围获取BloodPressureEverydayData
    public func selectBloodPressureEverydayDataList(byUserId userId: Int64?, withDate date: Date = Date(), withDayOffset dayOffset: Int = 0) -> [BloodPressureEverydayData]{
        
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<BloodPressureEverydayData> = BloodPressureEverydayData.fetchRequest()
        let startDate = dayOffset >= 0 ? translate(date) : translate(date, withDayOffset: dayOffset)  //as NSDate
        let endDate = dayOffset >= 0 ? translate(date, withDayOffset: dayOffset) : translate(date)    //as NSDate
        let predicate = NSPredicate(format: "user.userId = \(uid) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch blood pressure everyday data with dayoffset error: \(error)")
        }
        return []
    }
    
    //根据日期范围获取BloodPressureEverydayData 日周月年
    public func selectBloodPressureEverydayDataList(byUserId userId: Int64?, withDate date: Date = Date(), withCDHRange cdhRange: CDHRange) -> [BloodPressureEverydayData]{
        
        guard let uid = userId else {
            return []
        }
        let request: NSFetchRequest<BloodPressureEverydayData> = BloodPressureEverydayData.fetchRequest()
        
        //根据条件创建查询
        var predicate: NSPredicate?
        switch cdhRange {
        case .day:
            let startDate = translate(date)
            let endDate = translate(date)
            predicate = NSPredicate(format: "user.userId = \(uid) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .week:
            let weekday = calendar.component(.weekday, from: date)
            let startDate = translate(date, withDayOffset: -weekday)
            let endDate = translate(date, withDayOffset: 7 - weekday)
            predicate = NSPredicate(format: "user.userId = \(uid) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .month:
            let day = calendar.component(.day, from: date)
            if let dayRange = calendar.range(of: .day, in: .month, for: date){
                let daysOfMonth = Int(dayRange.count)
                
                let startDate = translate(date, withDayOffset: -day)
                let endDate = translate(date, withDayOffset: daysOfMonth - day)
                predicate = NSPredicate(format: "user.userId = \(uid) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
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
                        predicate = NSPredicate(format: "user.userId = \(uid) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
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
            predicate = NSPredicate(format: "user.userId = \(uid)")
        }
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch blood pressure everyday data with range error: \(error)")
        }
        return []
    }
    
    //MARK:- 根据日期删除对应userId血压数据
    public func deleteBloodPressureEverydayData(byUserId userId: Int64, withDate date: Date = Date()){
        guard let bloodPressureEverydayData = selectBloodPressureEverydayData(byUserId: userId, withDate: date) else {
            return
        }
        
        context.delete(bloodPressureEverydayData)
        guard commit() else {
            return
        }
    }
    
    //MARK:- items操作
    public func createBloodPressureEverydayDataItem(byUserId userId: Int64?, withDate date: Date, withItemId itemId: Int16) -> BloodPressureEverydayDataItem?{
        //判断item是否存在
        var bloodPressureEverydayDataItem = selectBloodPressureEverydayDataItem(byUserId: userId, withDate: date, withItemId: itemId)
        if let oldItem = bloodPressureEverydayDataItem{
            return oldItem
        }
        bloodPressureEverydayDataItem = NSEntityDescription.insertNewObject(forEntityName: "BloodPressureEverydayDataItem", into: context) as? BloodPressureEverydayDataItem
        guard let newItem = bloodPressureEverydayDataItem else{
            return nil
        }
        
        newItem.id = itemId
        
        //插入BloodPressureEverydayData item列表
        guard let bloodPressureEverydayData = selectBloodPressureEverydayData(byUserId: userId, withDate: date) else {
            return nil
        }
        
        bloodPressureEverydayData.addToBloodPressureEverydayDataItemList(newItem)
        
        guard commit() else {
            return nil
        }
        return newItem
    }
    
    public func selectBloodPressureEverydayDataItem(byUserId userId: Int64?, withDate date: Date, withItemId itemId: Int16) -> BloodPressureEverydayDataItem?{
        guard let uid = userId else {
            return nil
        }
        
        let request: NSFetchRequest<BloodPressureEverydayDataItem> = BloodPressureEverydayDataItem.fetchRequest()
        let predicate = NSPredicate(format: "bloodPressureEverydayData.date = \(date) AND bloodPressureEverydayData.user.userId = \(uid)")
        request.predicate = predicate
        
        do {
            let resultList = try context.fetch(request)
            return resultList.first
        } catch let error {
            fatalError("<Core Data> fetch blood pressure everyday data item error: \(error)")
        }
        return nil
    }
}
