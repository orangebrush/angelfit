//
//  CDH+User.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/5.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData

//MARK:- 获取体重方式
public enum WeightComponent {
    case day
    case week
    case month
    case year
    case all
}

//MARK:- User
extension CoreDataHandler{
    //初始化 user: with userid
    public func insertUser(userId id: Int64?) -> User?{
        
        //判断user是否存在
        var user = selectUser(userId: id)

        if user == nil{
            let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: context)
            user = User(entity: entityDescription!, insertInto: context)
            user?.userId

            guard commit() else {
                return nil
            }
        }
        return user
    }
    
    //获取 user
    public func selectUser(userId id: Int64?) -> User?{
        pthread_mutex_lock(&CoreDataHandler.rwlock)
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        let predicate = NSPredicate(format: "userId = \(id)", "")
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            pthread_mutex_unlock(&CoreDataHandler.rwlock)
            if resultList.isEmpty {
                return nil
            }else{
                return resultList[0]
            }
        }catch let error{
            print(error)
            pthread_mutex_unlock(&CoreDataHandler.rwlock)
            return nil
        }
    }
    
    //设置 user
    public func updateUser(userId id: Int16 = 1, withItems items: [String: Any]){
        do{
            try update(User.self, byConditionFormat: "userId = 1", withUpdateItems: items)
        }catch let error{
            print(error)
        }
    }
    
    //删除 user
    public func deleteUser(userId id: Int16 = 1){
        
        do{
            try delete(User.self, byConditionFormat: "userId = \(id)")
        }catch let error{
            print(error)
        }
    }
    
    //添加体重
    public func insertWeightItem(userId id: Int16 = 1, withDate date: Date, withValue value: Float) -> Weight?{
        //判断user是否存在
        let weightList = selectWeightByRange(userId: id, withDate: date, withDayRange: 0)
        guard weightList.isEmpty else {
            weightList.first?.date = translate(date) as NSDate?
            weightList.first?.value = value
            return weightList.first
        }
        
        //创建体重模型
        let weight = NSEntityDescription.insertNewObject(forEntityName: "Weight", into: context) as! Weight
        weight.date = translate(date) as NSDate?
        weight.value = value
        
        let user = selectUser(userId: id)
        user?.currentWeight = value
        user?.addToWeights(weight)
        
        guard commit() else {
            return nil
        }
        return weight
    }
    
    //获取体重 天周月年
    public func selectWeightByComponent(userId id: Int16 = 1, currentDate date: Date, withWeightComponent component: WeightComponent) -> [Weight]{
        let request: NSFetchRequest<Weight> = Weight.fetchRequest()
        
        let calendar = Calendar.current
        var predicate: NSPredicate?
        switch component {
        case .day:
            let startDate = translate(date)
            let endDate = translate(date)
            predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as! CVarArg, endDate as! CVarArg)
        case .week:
            let weekday = calendar.component(.weekday, from: date)
            let startDate = translate(date, withDayOffset: -weekday)
            let endDate = translate(date, withDayOffset: 7 - weekday)
            predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as! CVarArg, endDate as! CVarArg)
        case .month:
            let day = calendar.component(.day, from: date)
            if let dayRange = calendar.range(of: .day, in: .month, for: date){
                let daysOfMonth: Int = Int(dayRange.count)
                
                let startDate = translate(date, withDayOffset: -day)
                let endDate = translate(date, withDayOffset: daysOfMonth - day)
                predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as! CVarArg, endDate as! CVarArg)
            }
        case .year:
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.month = 1
            components.day = 1
            let startDate = calendar.date(from: components)
            if let year = components.year{
                components.year = year + 1
            }
            let endDate = translate(calendar.date(from: components)!, withDayOffset: -1)
            predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as! CVarArg, endDate as! CVarArg)
        case .all:
            predicate = NSPredicate(format: "user.userId = \(id)")
        }
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            debugPrint(error)
        }
        return []
    }
    
    //获取体重 偏移天数
    public func selectWeightByRange(userId id: Int16 = 1, withDate date: Date, withDayRange dayRange: Int = 0) -> [Weight]{
        let request: NSFetchRequest<Weight> = Weight.fetchRequest()
        let startDate = translate(date)
        let endDate = translate(date, withDayOffset: dayRange)
        let predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as! CVarArg, endDate as! CVarArg)
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            debugPrint(error)
        }
        return []
    }
}
