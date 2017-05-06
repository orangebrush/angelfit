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
    public func insertUserActivity() -> UserActivity?{
        
        guard let id = currentUserId() else {
            return nil
        }
        
        //判断是否有用户
        guard let user = selectUser(withUserId: id) else{
            return nil
        }
        
        //创建设备模型
        if let userActivity = NSEntityDescription.insertNewObject(forEntityName: "UserActivity", into: context) as? UserActivity{
            
            //为用户添加活动项信息
            user.addToUserActivityList(userActivity)
            
            //添加关系表... ontToOne
            
            guard commit() else {
                return nil
            }
            
            return userActivity
        }
        return nil
    }
    
    //获取 device
    public func selectUserActivity() -> UserActivity?{
        
        guard let id = currentUserId() else {
            return nil
        }
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<UserActivity> = UserActivity.fetchRequest()
        let predicate = NSPredicate(format: "user.userId = \(id)")
        request.predicate = predicate
        do{
            
            let resultList = try context.fetch(request)
            if resultList.isEmpty {
                return nil
            }else{
                return resultList[0]
            }
            
        }catch let error{
            print(error)
        }
        return nil
    }
    
    //删除 device
    public func deleteUserActivity(userId id: Int16 = 1, withMacAddress macAddress: String){
        delete(Device.self, byConditionFormat: "user.userId = \(id)")
    }
}
