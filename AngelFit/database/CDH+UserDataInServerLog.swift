//
//  CDH+UserDataInServerLog.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/6.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    public func userDataInServerLog() -> UserDataInServerLog?{
        
        //判断user是否存在
        var userDataInServerLog = selectUserDataInServerLog()
        
        if userDataInServerLog == nil{
            if let entityDescription = NSEntityDescription.entity(forEntityName: "UserDataInServerLog", in: context){
                userDataInServerLog = UserDataInServerLog(entity: entityDescription, insertInto: context)
                
                userDataInServerLog?.lastUpdatedTime = Date() as NSDate
                
                guard commit() else {
                    return nil
                }
            }else{
                fatalError("<Core Data> userhome description not exist!")
                return nil
            }
        }
        return userDataInServerLog
    }
    
    //查找 userhome
    func selectUserDataInServerLog() -> UserDataInServerLog?{
        
        let request: NSFetchRequest<UserDataInServerLog> = UserDataInServerLog.fetchRequest()
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
}
