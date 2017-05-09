//
//  CDH+UserSyncToServerLog.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/9.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    
    //MARK:- 插入
    public func insertUserSyncToServerLog(withFromDate fromDate: Date = Date(), withToDate toDate: Date = Date()) -> UserSyncToServerLog?{
        guard let uid = mainUserId() else {
            return nil
        }
        
        guard let userSyncToServerLog = NSEntityDescription.insertNewObject(forEntityName: "UserSyncToServerLog", into: context) as? UserSyncToServerLog else {
            return nil
        }
        
        userSyncToServerLog.fromTime = fromDate as NSDate
        userSyncToServerLog.toTime = fromDate as NSDate
        userSyncToServerLog.lastSyncTime = Date() as NSDate
        
        guard let user = selectUser(withUserId: uid) else {
            return nil
        }
        
        user.addToUserSyncToServerLogList(userSyncToServerLog)
        
        guard commit() else {
            return nil
        }
        
        return userSyncToServerLog
    }
    
    //MARK:- 根据偏移获取UserSyncToServerLog
    public func selectUserSyncToServerLogList(withDate date: Date, withDayOffset dayOffset: Int = 0) -> [UserSyncToServerLog]{
        
        guard let uid = mainUserId() else {
            return []
        }
        
        let request: NSFetchRequest<UserSyncToServerLog> = UserSyncToServerLog.fetchRequest()
        let startDate = dayOffset >= 0 ? translate(date) : translate(date, withDayOffset: dayOffset)
        let endDate = dayOffset >= 0 ? translate(date, withDayOffset: dayOffset) : translate(date)
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
