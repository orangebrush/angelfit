//
//  CDH_UserActivityLiker.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/8.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    public func insertUserActivityLiker(byObjectId objectId: Int64, byUserId userId: Int64? = nil) -> UserActivityLiker?{
        
        guard let userActivity = selectUserActivity(withObjectId: objectId, byUserId: userId) else{
            return nil
        }
        
        var id: Int16 = 0
        if let lastUserActivityLiker = selectAllUserActivityLikers(byObjectId: objectId, byUserId: userId).last{
            id = lastUserActivityLiker.id + 1         //增1
        }
        
        guard let userActivityLiker = NSEntityDescription.insertNewObject(forEntityName: "UserActivityLiker", into: context) as? UserActivityLiker else{
            return nil
        }
        
        userActivityLiker.id = id
        
        userActivity.addToUserActivityCommentList(userActivityLiker)
        
        guard commit() else {
            return nil
        }
        return userActivityLiker
    }
    
    public func selectAllUserActivityLikers(byObjectId objectId: Int64, byUserId userId: Int64? = nil) -> [UserActivityLiker]{
        
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //查找
        let request: NSFetchRequest<UserActivityLiker> = UserActivityLiker.fetchRequest()
        let predicate = NSPredicate(format: "userActivity.user.userId = \(id) AND userActivity.objectId = \(objectId)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch error: \(error)")
        }
        return []
    }
    
    public func deleteUserActivityLiker(byId id: Int64, byObjectId objectId: Int64, byUserId userId: Int64? = nil){
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return
        }
        delete(UserActivityLiker.self, byConditionFormat: "id = \(id), userActivity.user.userId = \(uid) AND userActivity.objectId = \(objectId)")
    }
}
