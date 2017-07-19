//
//  CDH+UserFamily.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/6.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
//MARK:- userhome
extension CoreDataHandler{
    //插入家庭用户
    func insertUserFamily() -> UserFamily?{
        
        //判断user是否存在
        var userFamily = selectUserFamily()
        
        if userFamily == nil{
            if let entityDescription = NSEntityDescription.entity(forEntityName: "UserFamily", in: context){
                userFamily = UserFamily(entity: entityDescription, insertInto: context)

                guard commit() else {
                    return nil
                }
            }else{
                fatalError("<Core Data> userhome description not exist!")
                return nil
            }
        }
        return userFamily
    }
    
    //查找 userhome
    func selectUserFamily() -> UserFamily?{
        
        let request: NSFetchRequest<UserFamily> = UserFamily.fetchRequest()
        let predicate = NSPredicate()
        
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
    
    //切换用户
    public func switchUser(withUserId userId: Int64?) -> User?{
        
        guard let id = userId else {
            return nil
        }
        
        guard let user = selectUser(withUserId: id) else {
            return nil
        }
        
        //设置在线用户userId
        insertUserFamily()?.isOnlineUserId = id
        
        guard commit() else {
            return nil
        }
        
        //设置存储userId
        
        return user
    }
    
    //获取主用户userId
    public func mainUserId() -> Int64?{
        guard let userFamily = insertUserFamily() else {
            return nil
        }
        
        return userFamily.userId
    }
    
    //获取当前登录用户userId
    public func currentUserId() -> Int64?{
        guard  let userFamily = insertUserFamily() else {
            return nil
        }
        return userFamily.isOnlineUserId
    }
}
