//
//  CoreDataHandler.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/2.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData

//数据库错误信息
enum GodError: Error{
    case fetchNoResult
}

//数据库表类
fileprivate enum TableClass: String{
    case user = "User"                      //用户
    case device = "Device"                  //设备
    
    case lostFind = "LostFind"              //丢失查找
    case unit = "Unit"                      //单位
    case alarm = "Alarm"                    //闹钟
    case longSit = "LongSit"                //久坐提醒
    case handGesture = "HandGesture"        //手势
    case notice = "Notice"                  //提醒
    
    case sportData = "SportData"            //运动数据
    case sportItem = "SportItem"            //运动详情
    case sleepData = "SleepData"            //睡眠数据
    case sleepItem = "SleepItem"            //睡眠详情
    case heartRateData = "HeartRateData"    //心率数据
    case heartRateItem = "HeartRateItem"    //心率详情
}


class CoreDataHandler {
    
    //MARK:- init
    init() {
        config()
    }
    
    private func config(){
        
        guard selectUser() != nil else{
            return
        }
        
        insertUser()
    }
    
    //coredata-context
    fileprivate let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    //MARK:- *增* insertTable with tableName and initKeyValue
    fileprivate func insert(_ tableClass: NSManagedObject.Type, withInitItems initItems: [String: Any]? = nil) throws {

        do{
            let tableObject = NSEntityDescription.insertNewObject(forEntityName: "\(tableClass.self)", into: context)
            
            if let items = initItems {
                tableObject.setValuesForKeys(items)
            }
            try context.save()
        }catch let error{
            throw error
        }
    }
    
    //MARK:- *删* deleteTable by condition
    fileprivate func delete(_ tableClass: NSManagedObject.Type, byConditionFormat conditionFormat: String) throws {
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "\(tableClass.self)", in: context)
        request.entity = entityDescription

        let predicate = NSPredicate(format: conditionFormat, "")
        request.predicate = predicate

        do{
            let resultList = try context.fetch(request) as! [NSManagedObject]
            if resultList.isEmpty {
                throw GodError.fetchNoResult
            }else{
                context.delete(resultList[0])
                try context.save()
            }
        }catch let error{
            throw error
        }
    }
    
    //MARK:- *查* selectTable by condition
    fileprivate func select(_ tableClass: NSManagedObject.Type, byConditionFormat conditionFormat: String) throws -> NSManagedObject{
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "\(tableClass.self)", in: context)
        request.entity = entityDescription
        
        let predicate = NSPredicate(format: conditionFormat, "")
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request) as! [NSManagedObject]
            
            if resultList.isEmpty {
                throw GodError.fetchNoResult
            }else{
                return resultList[0]
            }
        }catch let error{
            throw error
        }
    }
    
    //MARK:- *改* updateTable by condition with keyValue
    fileprivate func update(_ tableClass: NSManagedObject.Type, byConditionFormat conditionFormat: String, withUpdateItems items: [String: Any]) throws{
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "\(tableClass.self)", in: context)
        request.entity = entityDescription
        
        let predicate = NSPredicate(format: conditionFormat, "")
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request) as! [NSManagedObject]
            if resultList.isEmpty {
                throw GodError.fetchNoResult
            }else{
                resultList[0].setValuesForKeys(items)
                try context.save()
            }
        }catch let error{
            throw error
        }
    }
}

//MARK:- 提供数据库操作接口
extension CoreDataHandler{
    
    //初始化 user: with userid
    func insertUser(userId id: Int16 = 1) -> Bool{
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        user.userId = id

        do{
            try context.save()
            return true
        }catch let error{
            print(error)
        }
        
        return false
    }
    
    //获取 user
    func selectUser(userId id: Int16 = 1) -> User?{
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: context)
        request.entity = entityDescription
        
        let predicate = NSPredicate(format: "id = \(id)", "")
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request) as! [User]
            if resultList.isEmpty {
                return nil
            }else{
                return resultList[0]
            }
        }catch let error{
            return nil
        }
    }
    
    //设置 user
    func updateUser(_ items: [String: Any]){
        do{
            try update(User.self, byConditionFormat: "id = 1", withUpdateItems: items)
        }catch let error{
            print(error)
        }
    }
    
    //初始化 device
    func insertDevice() -> Bool{
        let device = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context) as! Device

        let user = NSEntityDescription.entity(forEntityName: "User", in: context) as! User
        user.addToDevices(device)
        return true
    }
}
