//
//  CDH+User.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/5.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
//MARK:- User
extension CoreDataHandler{
    
    //MARK:- 判断userId 默认获取mainUserId 并返回
    func checkoutUserId(withOptionUserId userId: String? = nil) -> String?{
        //判断userId
        var optionId: String?
        if userId == nil {
            optionId = mainUserId()
        }else{
            optionId = userId
        }
        guard let uid = optionId else {
            return nil
        }
        return uid
    }
    
    //插入用户
    public func insertUser(withUserId userId: String?) -> User?{
        
        guard let uid = userId else {
            return nil
        }
        
        //判断是否存在userHome
        guard let userFamily = insertUserFamily() else {
            return nil
        }
        
        //判断user是否存在，否则创建
        var user = selectUser(withUserId: uid)
        if user == nil{
            user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User
            
            user?.userId = uid
            
            //添加关系表... oneToOne
            user?.goal = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as? Goal
            user?.unitSetting = NSEntityDescription.insertNewObject(forEntityName: "UnitSetting", into: context) as? UnitSetting
            user?.userInfo = NSEntityDescription.insertNewObject(forEntityName: "UserInfo", into: context) as? UserInfo
            user?.userPhoneInfo = NSEntityDescription.insertNewObject(forEntityName: "UserPhoneInfo", into: context) as? UserPhoneInfo
            
            //添加user进userHome
            if let u = user {
                //如果用户为第一个添加，则设置为主用户
                if userFamily.users?.count == 0{
                    userFamily.userId = uid
                }
                
                userFamily.addToUsers(u)
                
                guard commit() else {
                    return nil
                }
                return u
            }
            return nil
        }
        
        //设置家庭用户为已同步
        userFamily.isSyncedToServer = true
        
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
    func selectUser(withUserId userId: String?) -> User?{
        
        guard let uid = userId else {
            return nil
        }
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "userId = \"\(uid)\"")
        
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
    public func deleteUser(withUserId userId: String?){
        guard let id = userId else {
            return
        }
        delete(User.self, byConditionFormat: "userId = \"\(id)\"")
    }
}
