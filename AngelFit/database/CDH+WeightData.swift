//
//  CDH+WeightData.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/9.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    //添加体重
    public func insertWeightData(withDate date: Date, withValue value: Int, withAccessoryId accessoryId: String) -> WeightData?{
        
        //转换体重数据
        let newWeight = Int32(value * 10000)
        
        //判断user是否存在 (一天仅能设置一次体重?)
        /*
         let weightList = selectWeightByRange(withUserId: id, withDate: date, withDayRange: 0)
         guard weightList.isEmpty else {
         weightList.first?.loggedAt = translate(date) as NSDate
         weightList.first?.weight10000TimesKG = newWeight
         guard commit() else {
         return nil
         }
         return weightList.first
         }
         */
        
        //一并创建userActivity
        guard let userActivity = insertUserActivity(withActivityType: kCDHUserActivityTypeWeight, withAccessoryId: accessoryId) else{
            return nil
        }
        
        //创建体重模型
        let weightData = NSEntityDescription.insertNewObject(forEntityName: "WeightData", into: context) as! WeightData
        weightData.date = date as NSDate?
        weightData.weight10000TimesKG = newWeight
        weightData.objectId = userActivity.objectId
        
        let user = selectUser(withUserId: currentUserId())
        user?.userInfo?.weight10000TimesKG = newWeight
        user?.addToWeightDataList(weightData)
        
        guard commit() else {
            return nil
        }
        return weightData
    }
    
    //获取体重 天周月年
    public func selectWeightDataList(withUserId userId: String?, withDate date: Date, withCDHRange cdhRange: CDHRange) -> [WeightData]{
        
        guard let uid = userId else {
            return []
        }
        let request: NSFetchRequest<WeightData> = WeightData.fetchRequest()
        
        //根据条件创建查询
        var predicate: NSPredicate?
        switch cdhRange {
        case .day:
            let startDate = translate(date)
            let endDate = translate(date)
            predicate = NSPredicate(format: "user.userId = \"\(uid)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .week:
            let weekday = calendar.component(.weekday, from: date)
            let startDate = translate(date, withDayOffset: -weekday)
            let endDate = translate(date, withDayOffset: 7 - weekday)
            predicate = NSPredicate(format: "user.userId = \"\(uid)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .month:
            let day = calendar.component(.day, from: date)
            if let dayRange = calendar.range(of: .day, in: .month, for: date){
                let daysOfMonth: Int = Int(dayRange.count)
                
                let startDate = translate(date, withDayOffset: -day)
                let endDate = translate(date, withDayOffset: daysOfMonth - day)
                predicate = NSPredicate(format: "user.userId = \"\(uid)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
            }
        case .year:
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.month = 1
            components.day = 1
            let startDate = translate(calendar.date(from: components)!.GMT())
            if let year = components.year{
                components.year = year + 1
            }
            let endDate = translate(calendar.date(from: components)!.GMT(), withDayOffset: -1)
            predicate = NSPredicate(format: "user.userId = \"\(uid)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .all:
            predicate = NSPredicate(format: "user.userId = \"\(uid)\"")
        }
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> weight error: \(error)")
        }
        return []
    }
    
    //获取体重 偏移天数
    public func selectWeightDataList(withUserId userId: String? , withDate date: Date, withDayOffset dayOffset: Int = 0) -> [WeightData]{
        
        guard let uid = userId else {
            return []
        }
        
        let request: NSFetchRequest<WeightData> = WeightData.fetchRequest()
        let startDate = dayOffset >= 0 ? translate(date) : translate(date, withDayOffset: dayOffset)
        let endDate = dayOffset >= 0 ? translate(date, withDayOffset: dayOffset) : translate(date)
        let predicate = NSPredicate(format: "user.userId = \"\(uid)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> weight error: \(error)")
        }
        return []
    }
}
