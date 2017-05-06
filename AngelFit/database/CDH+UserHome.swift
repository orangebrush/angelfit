//
//  CDH+UserHome.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/6.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
//MARK:- userhome
extension CoreDataHandler{
    //插入用户
    func userHome() -> UserHome?{
        
        //判断user是否存在
        var userHome = selectUserHome()
        
        if userHome == nil{
            if let entityDescription = NSEntityDescription.entity(forEntityName: "UserHome", in: context){
                userHome = UserHome(entity: entityDescription, insertInto: context)
                
                guard commit() else {
                    return nil
                }
            }else{
                fatalError("<Core Data> userhome description not exist!")
                return nil
            }
        }
        return userHome
    }
    
    //查找 userhome
    func selectUserHome() -> UserHome?{
        
        let request: NSFetchRequest<UserHome> = UserHome.fetchRequest()
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
        userHome()?.isOnlineUserId = id
        
        guard commit() else {
            return nil
        }
        
        //设置存储userId
        
        return user
    }
    
    //获取当前登录用户userId
    public func currentUserId() -> Int64?{
        guard  let userHome = userHome() else {
            return nil
        }
        
        let userId = userHome.isOnlineUserId
        return userId
    }
}
