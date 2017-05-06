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
    
    //插入用户
    public func insertUser(withUserId userId: Int64?) -> User?{
        
        guard let id = userId else {
            return nil
        }
        
        //判断是否存在userHome
        guard let userHome = userHome() else {
            return nil
        }
        
        //判断user是否存在，否则创建
        var user = selectUser(withUserId: id)
        if user == nil{
            user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User
            
            user?.userId = id
            
            //添加关系表... ontToOne
            user?.goal = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as? Goal
            user?.mindBodyState = NSEntityDescription.insertNewObject(forEntityName: "MindBodyState", into: context) as? MindBodyState
            user?.unitSetting = NSEntityDescription.insertNewObject(forEntityName: "UnitSetting", into: context) as? UnitSetting
            user?.userInfo = NSEntityDescription.insertNewObject(forEntityName: "UserInfo", into: context) as? UserInfo
            user?.userPhoneInfo = NSEntityDescription.insertNewObject(forEntityName: "UserPhoneInfo", into: context) as? UserPhoneInfo
            user?.userSyncToServerLog = NSEntityDescription.insertNewObject(forEntityName: "UserSyncToServerLog", into: context) as? UserSyncToServerLog
            
            //添加user进userHome
            if let u = user {
                //如果用户为第一个添加，则设置为主用户
                if userHome.users?.count == 0{
                    userHome.userId = id
                }
                
                userHome.addToUsers(u)
                
                guard commit() else {
                    return nil
                }
            }else{
                return nil
            }
        }
        
        //设置家庭用户为已同步
        userHome.isSyncedToServer = true
        guard commit() else {
            return nil
        }
        
        return user
    }
    
    //获取当前user
    public func currentUser() -> User?{
        return selectUser(withUserId: currentUserId())
    }
    
    //根据userId获取 user
    func selectUser(withUserId userId: Int64?) -> User?{
        
        guard let id = userId else {
            return nil
        }
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "userId = \(id)")
        
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
    
    //获取所有user
    public func allUser() -> [User]{
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate()
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch error: \(error)")
            return []
        }
    }
    
    //删除 user
    public func deleteUser(withUserId userId: Int64?){
        guard let id = userId else {
            return
        }
        delete(User.self, byConditionFormat: "userId = \(id)")
    }
    
    //添加体重
    public func insertWeightItem(withDate date: Date, withValue value: Int) -> WeightData?{
        
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
        
        //创建体重模型
        let weightData = NSEntityDescription.insertNewObject(forEntityName: "WeightData", into: context) as! WeightData
        weightData.loggedAt = date as NSDate?
        weightData.weight10000TimesKG = newWeight
        
        let user = selectUser(withUserId: currentUserId())
        user?.userInfo?.weight10000TimesKG = newWeight
        user?.addToWeightDataList(weightData)
        
        guard commit() else {
            return nil
        }
        return weightData
    }
    
    //获取体重 天周月年
    public func selectWeightByComponent(withUserId userId: Int64?, currentDate date: Date, withWeightComponent component: WeightComponent) -> [WeightData]{
        
        guard let id = userId else {
            return []
        }
        let request: NSFetchRequest<WeightData> = WeightData.fetchRequest()
        
        //根据条件创建查询
        var predicate: NSPredicate?
        switch component {
        case .day:
            let startDate = translate(date)
            let endDate = translate(date)
            predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .week:
            let weekday = calendar.component(.weekday, from: date)
            let startDate = translate(date, withDayOffset: -weekday)
            let endDate = translate(date, withDayOffset: 7 - weekday)
            predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .month:
            let day = calendar.component(.day, from: date)
            if let dayRange = calendar.range(of: .day, in: .month, for: date){
                let daysOfMonth: Int = Int(dayRange.count)
                
                let startDate = translate(date, withDayOffset: -day)
                let endDate = translate(date, withDayOffset: daysOfMonth - day)
                predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
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
            predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        case .all:
            predicate = NSPredicate(format: "user.userId = \(id)")
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
    public func selectWeightByRange(withUserId userId: Int64? , withDate date: Date, withDayRange dayRange: Int = 0) -> [WeightData]{
        
        guard let id = userId else {
            return []
        }
        
        let request: NSFetchRequest<WeightData> = WeightData.fetchRequest()
        let startDate = translate(date)
        let endDate = translate(date, withDayOffset: dayRange)
        let predicate = NSPredicate(format: "user.userId = \(id) AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
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
