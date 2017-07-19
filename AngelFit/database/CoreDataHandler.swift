//
//  CoreDataHandler.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/2.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

//数据库错误信息
public enum GodError: Error{
    case fetchNoResult
}

public class CoreDataHandler {
    
    //coredata-context
    let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
    
    //日历
    let calendar = Calendar.current
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    //MARK:- 加载编译后数据模型路径 momd
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Frameworks/AngelFit.framework/FunsportDataModel", withExtension: "momd")!
        debugPrint("<Core Data> mode url: \(modelURL)")
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    //MARK:- 设置数据库写入路径 并范围数据库协调器
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("funsport.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            debugPrint("<Core Data> Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    //读写锁
    static var rwlock: pthread_mutex_t = pthread_mutex_t()
    
    //MARK:- class init *****************************************************************************************************
    private static var __once: () = {
        singleton.instance = CoreDataHandler()
    }()
    struct singleton{
        static var instance:CoreDataHandler? = nil
    }
    public class func share() -> CoreDataHandler{
        _ = CoreDataHandler.__once
        return singleton.instance!
    }
    
    //MARK:- init *****************************************************************************************************
    public init() {
        config()
    }
    
    private func config(){
        pthread_mutex_init(&CoreDataHandler.rwlock, nil)
        
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
    }
    
    //MARK:- 修正日期 范围包含年月日日期
    func translate(_ date: Date, withDayOffset offset: Int = 0) -> Date{
        
        let resultDate = Date(timeInterval: TimeInterval(offset) * 60 * 60 * 24, since: date)
        
        let components = calendar.dateComponents([.year, .month, .day], from: resultDate)
        
        return calendar.date(from: components)!
    }
    
    // MARK: - Core Data Saving support
    public func commit() -> Bool{
        if context.hasChanges {
            do {
                debugPrint("<Core Data Commit> context:", context)
                try context.save()
                return true
            } catch let error {
                fatalError("<Core Data Commit> error context: \(context), error: \(error)")
                abort()
            }
        }
        debugPrint("<Core Data Commit> context has no changes!")
        return false
    }
    
    //MARK:- 丢弃修改
    public func reset() -> Bool{
        if context.hasChanges {
            context.reset()
            return true
        }
        return false
    }
    
    //MARK:- *增* insertTable with tableName and initKeyValue
    fileprivate func insert(_ tableClass: NSManagedObject.Type, withInitItems initItems: [String: Any]? = nil) throws {
        
        let tableObject = NSEntityDescription.insertNewObject(forEntityName: "\(tableClass.self)", into: context)
        
        if let items = initItems {
            tableObject.setValuesForKeys(items)
        }
        
        guard commit() else{
            return
        }
    }
    
    //MARK:- *删* deleteTable by condition
    func delete(_ tableClass: NSManagedObject.Type, byConditionFormat conditionFormat: String) {
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "\(tableClass.self)", in: context)
        request.entity = entityDescription
        
        let predicate = NSPredicate(format: conditionFormat)
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request) as! [NSManagedObject]
            if let last = resultList.last{
                context.delete(last)
                guard commit() else{
                    return
                }
            }else{
                fatalError("<Core Data> delete not exist result")
            }
        }catch let error{
            fatalError("<Core Data Delete> \(tableClass) error: \(error)")
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
        
        let resultList = try context.fetch(request) as! [NSManagedObject]
        if resultList.isEmpty {
            throw GodError.fetchNoResult
        }else{
            resultList[0].setValuesForKeys(items)
            guard commit() else{
                return
            }
        }
    }
}
