//
//  CDH+MindBodyState.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/9.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    
    //添加心情
    public func insertMindBodyState(withDate date: Date, withCDHMindBodyState cdhMindBodystate: CDHMindBodyState) -> MindBodyState?{

        //一并创建userActivity
        guard let userActivity = insertUserActivity(withActivityType: kCDHUserActivityTypeMood) else{
            return nil
        }
        
        //创建心情模型
        let mindBodyState = NSEntityDescription.insertNewObject(forEntityName: "MindBodyState", into: context) as! MindBodyState
        mindBodyState.date = date as NSDate?
        mindBodyState.mindBodyState = cdhMindBodystate.rawValue
        mindBodyState.objectId = userActivity.objectId
        
        let user = selectUser(withUserId: mainUserId())
        user?.addToMindBodyStateList(mindBodyState)
        
        guard commit() else {
            return nil
        }
        return mindBodyState
    }
    
    //获取心情 天周月年
    public func selectMindBodyStateList(withUserId userId: Int64?, withDate date: Date, withCDHRange cdhRange: CDHRange) -> [MindBodyState]{
        
        guard let uid = userId else {
            return []
        }
        let request: NSFetchRequest<MindBodyState> = MindBodyState.fetchRequest()
        
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
                let daysOfMonth: Int = Int(dayRange.count)
                
                let startDate = translate(date, withDayOffset: -day)
                let endDate = translate(date, withDayOffset: daysOfMonth - day)
                predicate = NSPredicate(format: "user.userId = \(uid) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
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
            predicate = NSPredicate(format: "user.userId = \(uid) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .all:
            predicate = NSPredicate(format: "user.userId = \(uid)")
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
    
    //获取心情 偏移天数
    public func selectMindBodyStateList(withUserId userId: Int64? , withDate date: Date, withDayOffset dayOffset: Int = 0) -> [MindBodyState]{
        
        guard let uid = userId else {
            return []
        }
        
        let request: NSFetchRequest<MindBodyState> = MindBodyState.fetchRequest()
        let startDate = translate(date)
        let endDate = translate(date, withDayOffset: dayOffset)
        let predicate = NSPredicate(format: "user.userId = \(uid) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
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
