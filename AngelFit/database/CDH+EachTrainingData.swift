//
//  CDH+EachTrainingData.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/9.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
//MARK:- EachTrainningData
extension CoreDataHandler{
    
    //插入单日运动数据
    public func insertEachTrainningData(withAccessoryId accessoryId: String, byUserId userId: String? = nil, withDate date: Date = Date()) -> EachTrainningData? {
        
        //判断是否已存在当日数据
        var eachTrainningData = selectEachTrainningData(withAccessoryId: accessoryId, byUserId: userId, withDate: date)
        if let oldResult = eachTrainningData {
            return oldResult
        }
        
        //判断userId
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //一并创建userActivity
        guard let userActivity = insertUserActivity(withActivityType: kCDHUserActivityTypeTrainingData, withAccessoryId: accessoryId) else{
            return nil
        }
        
        //创建插入对象
        eachTrainningData = NSEntityDescription.insertNewObject(forEntityName: "EachTrainningData", into: context) as? EachTrainningData
        guard let newResult = eachTrainningData  else {
            return nil
        }
        
        eachTrainningData?.objectId = userActivity.objectId
        
        //获取需插入的设备
        guard let device = selectDevice(withAccessoryId: accessoryId, byUserId: userId) else {
            return nil
        }
        device.addToEachTrainningDataList(newResult)
        
        guard commit() else {
            return nil
        }
        
        return newResult
    }
    
    //根据日期获取EachTrainningData
    public func selectEachTrainningData(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date = Date()) -> EachTrainningData?{
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<EachTrainningData> = EachTrainningData.fetchRequest()
        let predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\" AND date = %@", translate(date) as CVarArg)
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList.first
        }catch let error{
            fatalError("<Core Data> fetch blood pressure everyday data error: \(error)")
        }
        return nil
    }
    
    //根据日期范围获取EachTrainningData
    public func selectEachTrainningDataList(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date = Date(), withDayOffset dayOffset: Int = 0) -> [EachTrainningData]{
        
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<EachTrainningData> = EachTrainningData.fetchRequest()
        let startDate = dayOffset >= 0 ? translate(date) : translate(date, withDayOffset: dayOffset)  //as NSDate
        let endDate = dayOffset >= 0 ? translate(date, withDayOffset: dayOffset) : translate(date)    //as NSDate
        let predicate = NSPredicate(format: "device.accessoryId = \"\(accessoryId)\" AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch blood pressure everyday data with dayoffset error: \(error)")
        }
        return []
    }
    
    //根据日期范围获取EachTrainningData 日周月年
    public func selectEachTrainningDataList(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date = Date(), withCDHRange cdhRange: CDHRange) -> [EachTrainningData]{
        
        guard let uid = userId else {
            return []
        }
        let request: NSFetchRequest<EachTrainningData> = EachTrainningData.fetchRequest()
        
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
            fatalError("<Core Data> fetch blood pressure everyday data with range error: \(error)")
        }
        return []
    }
    
    //MARK:- 根据日期删除对应userId血压数据
    public func deleteEachTrainningData(withAccessoryId accessoryId: String, byUserId userId: String, withDate date: Date = Date()){
        guard let eachTrainningData = selectEachTrainningData(withAccessoryId: accessoryId, byUserId: userId, withDate: date) else {
            return
        }
        
        context.delete(eachTrainningData)
        guard commit() else {
            return
        }
    }
    
    //MARK:- 坐标操作
    public func createEachTrainningGPSLoggerItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16, withCoordinate2D coordinate: CLLocationCoordinate2D) -> EachTrainningGPSLoggerItem? {
        //判断item是否存在
        var eachTrainningGPSLoggerItem = selectEachTrainningGPSLoggerItem(withAccessoryId: accessoryId, byUserId: userId, withDate: date, withItemId: itemId)
        if let oldItem = eachTrainningGPSLoggerItem{
            return oldItem
        }
        eachTrainningGPSLoggerItem = NSEntityDescription.insertNewObject(forEntityName: "EachTrainningGPSLoggerItem", into: context) as? EachTrainningGPSLoggerItem
        guard let newItem = eachTrainningGPSLoggerItem else{
            return nil
        }
        
        newItem.id = itemId
        newItem.longtitude = coordinate.longitude
        newItem.latitude = coordinate.latitude
        
        //插入EachTrainningData item列表
        guard let eachTrainningData = selectEachTrainningData(withAccessoryId: accessoryId, byUserId: userId, withDate: date) else {
            return nil
        }
        
        eachTrainningData.addToGpsLoggerItems(newItem)
        
        guard commit() else {
            return nil
        }
        return newItem
    }
    
    public func selectEachTrainningGPSLoggerItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16) -> EachTrainningGPSLoggerItem? {
        guard let uid = userId else {
            return nil
        }
        
        let request: NSFetchRequest<EachTrainningGPSLoggerItem> = EachTrainningGPSLoggerItem.fetchRequest()
        let predicate = NSPredicate(format: "eachTrainningData.date = \(date) AND eachTrainningData.device.accessoryid = \"\(accessoryId)\"")
        request.predicate = predicate
        
        do {
            let resultList = try context.fetch(request)
            return resultList.first
        } catch let error {
            fatalError("<Core Data> fetch gps logger item everyday data item error: \(error)")
        }
        return nil
    }
    
    //MARK:- 心率操作
    public func createEachTrainningHeartRateItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16, withHeartrateValue hrValue: Int16) -> EachTrainningHeartRateItem? {
        //判断item是否存在
        var eachTrainningHeartRateItem = selectEachTrainningHeartRateItem(withAccessoryId: accessoryId, byUserId: userId, withDate: date, withItemId: itemId)
        if let oldItem = eachTrainningHeartRateItem{
            return oldItem
        }
        eachTrainningHeartRateItem = NSEntityDescription.insertNewObject(forEntityName: "EachTrainningHeartRateItem", into: context) as? EachTrainningHeartRateItem
        guard let newItem = eachTrainningHeartRateItem else{
            return nil
        }
        
        newItem.id = itemId
        newItem.value = Int32(hrValue)
        
        //插入EachTrainningData item列表
        guard let eachTrainningData = selectEachTrainningData(withAccessoryId: accessoryId, byUserId: userId, withDate: date) else {
            return nil
        }
        
        eachTrainningData.addToHeartRateActivityItems(newItem)
        
        guard commit() else {
            return nil
        }
        return newItem
    }
    
    public func selectEachTrainningHeartRateItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16) -> EachTrainningHeartRateItem? {
        guard let uid = userId else {
            return nil
        }
        
        let request: NSFetchRequest<EachTrainningHeartRateItem> = EachTrainningHeartRateItem.fetchRequest()
        let predicate = NSPredicate(format: "eachTrainningData.date = \(date) AND eachTrainningData.device.accessoryId = \"\(accessoryId)\"")
        request.predicate = predicate
        
        do {
            let resultList = try context.fetch(request)
            return resultList.first
        } catch let error {
            fatalError("<Core Data> fetch heartrate item error: \(error)")
        }
        return nil
    }
    
    //MARK:- 步数操作
    public func createEachTrainningStepItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16, withSteps steps: Int16) -> EachTrainningStepItem? {
        //判断item是否存在
        var eachTrainningStepItem = selectEachTrainningStepItem(withAccessoryId: accessoryId, byUserId: userId, withDate: date, withItemId: itemId)
        if let oldItem = eachTrainningStepItem{
            return oldItem
        }
        eachTrainningStepItem = NSEntityDescription.insertNewObject(forEntityName: "EachTrainningStepItem", into: context) as? EachTrainningStepItem
        guard let newItem = eachTrainningStepItem else{
            return nil
        }
        
        newItem.id = itemId
        newItem.steps = steps
        
        //插入EachTrainningData item列表
        guard let eachTrainningData = selectEachTrainningData(withAccessoryId: accessoryId, byUserId: userId, withDate: date) else {
            return nil
        }
        
        eachTrainningData.addToStepPreMinuteItems(newItem)
        
        guard commit() else {
            return nil
        }
        return newItem
    }
    
    public func selectEachTrainningStepItem(withAccessoryId accessoryId: String, byUserId userId: String?, withDate date: Date, withItemId itemId: Int16) -> EachTrainningStepItem? {
        guard let uid = userId else {
            return nil
        }
        
        let request: NSFetchRequest<EachTrainningStepItem> = EachTrainningStepItem.fetchRequest()
        let predicate = NSPredicate(format: "eachTrainningData.date = %@ AND eachTrainningData.device.accessoryId = \"\(accessoryId)\"", translate(date) as CVarArg)
        request.predicate = predicate
        
        do {
            let resultList = try context.fetch(request)
            return resultList.first
        } catch let error {
            fatalError("<Core Data> fetch step item error: \(error)")
        }
        return nil
    }
}
