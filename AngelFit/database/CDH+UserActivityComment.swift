//
//  CDH+UserActivityComment.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/8.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    
    public func insertUserActivityComment(byObjectId objectId: Int64, byUserId userId: Int64? = nil) -> UserActivityComment?{
        
        guard let userActivity = selectUserActivity(withObjectId: objectId, byUserId: userId) else{
            return nil
        }
        
        var id: Int64 = 0
        if let lastUserActivityComment = selectAllUserActivityComments(byObjectId: objectId, byUserId: userId).last{
            id = lastUserActivityComment.id + 1         //增1
        }
        
        guard let userActivityComment = NSEntityDescription.insertNewObject(forEntityName: "UserActivityComment", into: context) as? UserActivityComment else{
            return nil
        }
        
        userActivityComment.id = id
        
        userActivity.addToUserActivityCommentList(userActivityComment)
        
        guard commit() else {
            return nil
        }
        return userActivityComment
    }
    
    public func selectAllUserActivityComments(byObjectId objectId: Int64, byUserId userId: Int64? = nil) -> [UserActivityComment]{
        
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //查找
        let request: NSFetchRequest<UserActivityComment> = UserActivityComment.fetchRequest()
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
    
    public func deleteUserActivityComment(byId id: Int64, byObjectId objectId: Int64, byUserId userId: Int64? = nil){
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return
        }
        delete(UserActivityComment.self, byConditionFormat: "id = \(id), userActivity.user.userId = \(uid) AND userActivity.objectId = \(objectId)")
    }
}
