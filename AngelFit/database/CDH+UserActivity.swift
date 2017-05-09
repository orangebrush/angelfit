//
//  CDH+UserActivity.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/6.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
//MARK:- userActivity
extension CoreDataHandler{
    //初始化 device
    func insertUserActivity(withActivityType activityType: Int16) -> UserActivity?{
        
        guard let id = currentUserId() else {
            return nil
        }
        
        //判断是否有用户
        guard let user = selectUser(withUserId: id) else{
            return nil
        }
        
        //获取序列id
        var objectId: Int64 = 0
        let userActivityList = selectAllUserActivities(byUserId: id)
        if let lastUserActivity = userActivityList.last {
            objectId = lastUserActivity.objectId + 1        //增1
        }
        
        //创建设备模型
        if let userActivity = NSEntityDescription.insertNewObject(forEntityName: "UserActivity", into: context) as? UserActivity{
            
            //根据type与objectId标示唯一对象
            userActivity.type = activityType
            userActivity.objectId = objectId
            
            //为用户添加活动项信息
            user.addToUserActivityList(userActivity)
            
            guard commit() else {
                return nil
            }            
            return userActivity
        }
        return nil
    }
    
    //获取 device
    public func selectUserActivity(withObjectId objectId: Int64, byUserId userId: Int64? = nil) -> UserActivity?{
        
        //判断userId
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<UserActivity> = UserActivity.fetchRequest()
        let predicate = NSPredicate(format: "user.userId = \(id) AND objectId = \(objectId)")
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList.first
        }catch let error{
            fatalError("<Core Data> select user activity error: \(error), by userId: \(id)")
        }
        return nil
    }
    
    //MARK:- 获取所有userActivity
    public func selectAllUserActivities(byUserId userId: Int64? = nil) -> [UserActivity]{
        
        //判断userId
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<UserActivity> = UserActivity.fetchRequest()
        let predicate = NSPredicate(format: "user.userId = \(id)")
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> select all user activity error: \(error), by userId: \(id)")
        }
        return []
    }
    
    //删除 device
    public func deleteUserActivity(userId id: Int16 = 1, withMacAddress macAddress: String){
        delete(Device.self, byConditionFormat: "user.userId = \(id)")
    }
}
