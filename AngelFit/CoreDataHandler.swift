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
public enum GodError: Error{
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


public class CoreDataHandler {
    
    //coredata-context
    fileprivate let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    private let calender = Calendar.current
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    //MARK:- 加载编译后数据模型路径 momd
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = Bundle.main.url(forResource: "frameworks/AngelFit.framework/Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    //MARK:- 设置数据库写入路径 并范围数据库协调器
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("angelfitData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as! AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as! AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    
    //MARK:- init
    public init() {
        config()
    }
    
    private func config(){

        context.persistentStoreCoordinator = persistentStoreCoordinator

    }
    
    //MARK:- 修正日期 范围包含年月日日期
    fileprivate func translate(_ date: Date, withDayOffset offset: Int = 0) -> Date{
        
        let resultDate = Date(timeInterval: TimeInterval(offset) * 60 * 60 * 24, since: date)
        
        var components = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: resultDate)
        components.hour = 4
        components.minute = 0
        components.second = 0
        
        return calender.date(from: components)!
    }
    
    // MARK: - Core Data Saving support
    public func commit () -> Bool{
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch let error {

                print(error)
                abort()
            }
        }
        return false
    }
    
    //MARK:- *增* insertTable with tableName and initKeyValue
    fileprivate func insert(_ tableClass: NSManagedObject.Type, withInitItems initItems: [String: Any]? = nil) throws {
        
        let tableObject = NSEntityDescription.insertNewObject(forEntityName: "\(tableClass.self)", into: context)
        
        if let items = initItems {
            tableObject.setValuesForKeys(items)
        }
        
        commit()
    }
    
    //MARK:- *删* deleteTable by condition
    fileprivate func delete(_ tableClass: NSManagedObject.Type, byConditionFormat conditionFormat: String) throws {
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "\(tableClass.self)", in: context)
        request.entity = entityDescription

        let predicate = NSPredicate(format: conditionFormat, "")
        request.predicate = predicate

        let resultList = try context.fetch(request) as! [NSManagedObject]
        if resultList.isEmpty {
            throw GodError.fetchNoResult
        }else{
            
            context.delete(resultList[0])
            commit()
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
            commit()
        }
    }
}

//MARK:- User
extension CoreDataHandler{
    
    //初始化 user: with userid
    public func insertUser(userId id: Int16 = 1) -> User?{

        //判断user是否存在
        var user = selectUser(userId: id)
        guard user == nil else{
            return user
        }
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: context)
        user = User(entity: entityDescription!, insertInto: context)
        user?.userId = id

        guard commit() else {
            return nil
        }
        return user

    }
    
    //获取 user
    public func selectUser(userId id: Int16 = 1) -> User?{
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        let predicate = NSPredicate(format: "userId = \(id)", "")
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
            return nil
        }
    }
    
    //设置 user
    public func updateUser(userId id: Int16 = 1, withItems items: [String: Any]){
        do{
            try update(User.self, byConditionFormat: "userId = 1", withUpdateItems: items)
        }catch let error{
            print(error)
        }
    }
    
    //删除 user
    public func deleteUser(userId id: Int16 = 1){
       
        do{
            try delete(User.self, byConditionFormat: "userId = \(id)")
        }catch let error{
            print(error)
        }
    }
}

//MARK:- Device
extension CoreDataHandler{
    
    //初始化 device
    public func insertDevice(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> Device?{
        
        //判断设备是否以存在
        var device = selectDevice(userId: id, withMacAddress: macAddress)
        guard device == nil else{
            if let dict = items {
                device?.setValuesForKeys(dict)
            }
            commit()
            return device
        }
        
        //判断是否有用户
        guard let user = selectUser(userId: id) else{
            return nil
        }
        
        //创建设备模型
        device = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context) as! Device
        device?.macAddress = macAddress
        
        if let dict = items {
            device?.setValuesForKeys(dict)
        }
        commit()
        
        //为用户添加设备
        user.addToDevices(device!)
        guard commit() else {
            return nil
        }
        
        return device
    }
    
    //获取 device
    public func selectDevice(userId id: Int16 = 1, withMacAddress macAddress: String) -> Device?{
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<Device> = Device.fetchRequest()
        let predicate = NSPredicate(format: "user.userId = \(id) AND macAddress = '\(macAddress)'", "")
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
    
    //更新 device
    public func updateDevice(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        do{
            try update(Device.self, byConditionFormat: "macAddress = '\(macAddress)'", withUpdateItems: items)
        }catch let error{
            print(error)
        }
    }
    
    //删除 device
    public func deleteDevice(userId id: Int16 = 1, withMacAddress macAddress: String){
        do{
            try delete(Device.self, byConditionFormat: "user.userId = \(id) AND macAddress = '\(macAddress)'")
        }catch let error{
            print(error)
        }
    }
}

//MARK:- LongSit
extension CoreDataHandler{
    //插入 longSit
    public func insertLongSit(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> LongSit?{
        
        //判断longSit是否存在
        var longSit = selectLongSit(userID: id, withMacAddress: macAddress)
        guard longSit == nil else {
            if let dict = items {
                longSit?.setValuesForKeys(dict)
            }
            guard commit() else{
                return nil
            }
            return longSit
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建久坐数据模型
        longSit = NSEntityDescription.insertNewObject(forEntityName: "LongSit", into: context) as! LongSit
        
        if let dict = items {
            longSit?.setValuesForKeys(dict)
        }
        guard commit() else{
            return nil
        }
        
        //为设备添加久坐数据
        device.longSit = longSit
        
        guard commit() else{
            return nil
        }
        return longSit
    }
    
    //获取 longSit
    public func selectLongSit(userID id: Int16 = 1, withMacAddress macAddress: String) -> LongSit?{
        //根据设备获取久坐模型
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else{
            return nil
        }
        
        return device.longSit
    }
    
    //更新 longSit
    public func updateLongSit(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        guard let longSit = selectLongSit(userID: id, withMacAddress: macAddress) else{
            return
        }
        longSit.setValuesForKeys(items)
        commit()
    }
    
    //删除 longSit
    public func deleteLongSit(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let longSit = selectLongSit(userID: id, withMacAddress: macAddress) else {
            return
        }
        
        context.delete(longSit)
        commit()
    }
}

//MARK:- Notice
extension CoreDataHandler{
    //插入 notice
    public func insertNotice(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> Notice?{
        
        //判断notice是否存在
        var notice = selectNotice(userId: id, withMacAddress: macAddress)
        guard notice == nil else {
            if let dict = items{
                notice?.setValuesForKeys(dict)
            }
            commit()
            return notice
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建消息提醒模型
        notice = NSEntityDescription.insertNewObject(forEntityName: "Notice", into: context) as! Notice
        
        if let dict = items{
            notice?.setValuesForKeys(dict)
        }
        commit()
        
        //为设备添加消息提醒数据
        device.notice = notice
        guard commit() else{
            return nil
        }
        
        return notice
    }
    
    //获取 notice
    public func selectNotice(userId id: Int16 = 1, withMacAddress macAddress: String) -> Notice?{
        //根据设备获取消息提醒模型
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        return device.notice
    }
    
    //更新 notice
    public func updateNotice(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        guard let notice = selectNotice(userId: id, withMacAddress: macAddress) else {
            return
        }
        notice.setValuesForKeys(items)
        commit()
    }
    
    //删除 notice
    public func deleteNotice(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let notice = selectNotice(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(notice)
        commit()
    }
}

//MARK:- Unit
extension CoreDataHandler{
    //插入 unit
    public func insertUnit(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> Unit?{
        
        //判断unit是否存在
        var unit = selectUnit(userId: id, withMacAddress: macAddress)
        guard unit == nil else {
            if let dict = items{
                unit?.setValuesForKeys(dict)
            }
            commit()
            return unit
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        unit = NSEntityDescription.insertNewObject(forEntityName: "Unit", into: context) as! Unit
        
        if let dict = items{
            unit?.setValuesForKeys(dict)
        }
        commit()
        
        //为设备添加单位数据
        device.unit = unit
        guard commit() else {
            return nil
        }
        return unit
    }
    
    //获取 unit
    public func selectUnit(userId id: Int16 = 1, withMacAddress macAddress: String) -> Unit?{
        //根据设备获取单位模型
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        return device.unit
    }
    
    //更新 unit
    public func updateUnit(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        guard let unit = selectUnit(userId: id, withMacAddress: macAddress) else {
            return
        }
        unit.setValuesForKeys(items)
        commit()
    }
    
    //删除 unit
    public func deleteUnit(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let unit = selectUnit(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(unit)
        commit()
    }
}

//MARK:- Alarm
extension CoreDataHandler{
    //插入 alarm
    public func insertAlarm(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> Alarm?{
        
        //判断alarm是否存在
        var alarm = selectAlarm(userId: id, withMacAddress: macAddress)
        guard alarm == nil else {
            if let dict = items{
                alarm?.setValuesForKeys(dict)
            }
            commit()
            return alarm
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        alarm = NSEntityDescription.insertNewObject(forEntityName: "Alarm", into: context) as! Alarm
        
        if let dict = items{
            alarm?.setValuesForKeys(dict)
        }
        commit()
        
        //为设备添加闹钟数据
        device.alarm = alarm
        guard commit() else {
            return nil
        }
        return alarm
    }
    
    //获取 alarm
    public func selectAlarm(userId id: Int16 = 1, withMacAddress macAddress: String) -> Alarm?{
        //根据设备获取闹钟模型
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        return device.alarm
    }
    
    //更新 alarm
    public func updateAlarm(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        guard let alarm = selectAlarm(userId: id, withMacAddress: macAddress) else {
            return
        }
        alarm.setValuesForKeys(items)
        commit()
    }
    
    //删除 alarm
    public func deleteAlarm(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let alarm = selectAlarm(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(alarm)
        commit()
    }
}

//MARK:- HandGesture
extension CoreDataHandler{
    //插入 handGesture
    public func insertHandGesture(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> HandGesture?{
        
        //判断handGesture是否存在
        var handGesture = selectHandGesture(userId: id, withMacAddress: macAddress)
        guard handGesture == nil else {
            if let dict = items {
                handGesture?.setValuesForKeys(dict)
            }
            commit()
            return handGesture
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        handGesture = NSEntityDescription.insertNewObject(forEntityName: "HandGesture", into: context) as! HandGesture
        
        if let dict = items {
            handGesture?.setValuesForKeys(dict)
        }
        commit()
        
        //为设备添加手势数据
        device.handGesture = handGesture
        guard commit() else {
            return  nil
        }
        return handGesture
    }
    
    //获取 handGesture
    public func selectHandGesture(userId id: Int16 = 1, withMacAddress macAddress: String) -> HandGesture?{
        //根据设备获取手势模型
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        return device.handGesture
    }
    
    //更新 handGesture
    public func updateHandGesture(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        guard let handGesture = selectHandGesture(userId: id, withMacAddress: macAddress) else {
            return
        }
        handGesture.setValuesForKeys(items)
        commit()
    }
    
    //删除 handGesture
    public func deleteHandGesture(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let handGesture = selectHandGesture(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(handGesture)
        commit()
    }
}

//MARK:- LostFind
extension CoreDataHandler{
    //插入 lostFind
    public func insertLostFind(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> LostFind?{
        
        //判断lostFind是否存在
        var lostFind = selectLostFind(userId: id, withMacAddress: macAddress)
        guard lostFind == nil else {
            if let dict = items{
                lostFind?.setValuesForKeys(dict)
            }
            commit()
            return lostFind
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        lostFind = NSEntityDescription.insertNewObject(forEntityName: "LostFind", into: context) as! LostFind
        
        if let dict = items{
            lostFind?.setValuesForKeys(dict)
        }
        commit()
        
        //为设备添加防丢数据
        device.lostFind = lostFind
        guard commit() else {
            return nil
        }
        return lostFind
    }
    
    //获取 lostFind
    public func selectLostFind(userId id: Int16 = 1, withMacAddress macAddress: String) -> LostFind?{
        //根据设备获取防丢模型
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        return device.lostFind
    }
    
    //更新 lostFind
    public func updateLostFind(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        guard let lostFind = selectLostFind(userId: id, withMacAddress: macAddress) else {
            return
        }
        lostFind.setValuesForKeys(items)
        commit()
    }
    
    //删除 lostFind
    public func deleteLostFind(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let lostFind = selectLostFind(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(lostFind)
        commit()
    }
}

//MARK:- SportData
extension CoreDataHandler{
    
    //插入 sportData
    public func insertSportData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withItems items: [String: Any]? = nil) -> SportData?{
        
        //判断当前日期sportData是否存在
        let sportDataList = selectSportData(userId: id, withMacAddress: macAddress, withDate: date)
        guard sportDataList.isEmpty else {
            let sportData = sportDataList.first
            if let dict = items{
                sportData?.setValuesForKeys(dict)
            }
            commit()
            return sportDataList.first
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建运动数据模型
        let sportData = NSEntityDescription.insertNewObject(forEntityName: "SportData", into: context) as! SportData
        sportData.date = date as! NSDate
        
        if let dict = items{
            sportData.setValuesForKeys(dict)
        }
        commit()
        
        //为设备添加运动数据
        device.addToSportDatas(sportData)
        guard commit() else {
            return nil
        }
        
        return sportData
    }
    
    //获取 sportData
    public func selectSportData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withDayRange dayRange: Int = 0) -> [SportData]{
        //根据用户设备列表获取设备
        let request: NSFetchRequest<SportData> = SportData.fetchRequest()
        let startDate = translate(date) as! NSDate
        let endDate = translate(date, withDayOffset: dayRange) as! NSDate
        let predicate = NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date >= '\(startDate)' AND date <= '\(endDate)'", "")
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            print(error)
        }
        return []
    }
    
    //更新 sportData
    public func updateSportData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItems items: [String: Any]){
        guard let sportData = selectSportData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        sportData.setValuesForKeys(items)
        commit()
    }
    
    //删除 sportData
    public func deleteSportData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date){
        guard let sportData = selectSportData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        context.delete(sportData)
        commit()
    }
    
    //插入 sportItem
    public func createSportItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItemId itemId: Int16) -> SportItem?{
        //判断sportItem是否存在
        var sportItem = selectSportItem(userId: id, withMacAddress: macAddress, withDate: date, withItemId: itemId)
        guard sportItem == nil else {
            return sportItem
        }
        
        //判断sportData是否存在
        guard let sportData = selectSportData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return nil
        }
        
        sportItem = NSEntityDescription.insertNewObject(forEntityName: "SportItem", into: context) as! SportItem
        sportItem?.id = itemId
        commit()
        
        sportData.addToSportItem(sportItem!)
        
        guard commit() else {
            return nil
        }
        
        return sportItem
    }
    
    //获取 sportItem
    private func selectSportItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItemId itemId: Int16) -> SportItem?{
        
        let request: NSFetchRequest<SportItem> = SportItem.fetchRequest()
        let predicate = NSPredicate(format: "sportData.macAddress = \(macAddress) AND sportData.user.userId = \(id) AND sportData.date = '\(date)' AND id = \(itemId)", "")
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
}

//MARK:- SleepData
extension CoreDataHandler{
    
    //插入 sleepData
    public func insertSleepData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withItems items: [String: Any]? = nil) -> SleepData?{
        
        //判断当前日期sleepData是否存在
        let sleepDataList = selectSleepData(userId: id, withMacAddress: macAddress, withDate: date)
        guard sleepDataList.isEmpty else {
            let sleepData = sleepDataList.first
            if let dict = items{
                sleepData?.setValuesForKeys(dict)
            }
            commit()
            return sleepDataList.first
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建运动数据模型
        let sleepData = NSEntityDescription.insertNewObject(forEntityName: "SleepData", into: context) as! SleepData
        sleepData.date = date as! NSDate
        
        if let dict = items{
            sleepData.setValuesForKeys(dict)
        }
        commit()
        
        //为设备添加运动数据
        device.addToSleepDatas(sleepData)
        guard commit() else {
            return nil
        }
        
        return sleepData
    }
    
    //获取 sleepData
    public func selectSleepData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withDayRange dayRange: Int = 0) -> [SleepData]{
        //根据用户设备列表获取设备
        let request: NSFetchRequest<SleepData> = SleepData.fetchRequest()
        let startDate = translate(date) as! NSDate
        let endDate = translate(date, withDayOffset: dayRange) as! NSDate
        let predicate = NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date >= '\(startDate)' AND date <= '\(endDate)'", "")
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            print(error)
        }
        return []
    }
    
    //更新 sleepData
    public func updateSleepData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItems items: [String: Any]){
        guard let sleepData = selectSleepData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        sleepData.setValuesForKeys(items)
        commit()
    }
    
    //删除 sleepData
    public func deleteSleepData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date){
        guard let sleepData = selectSleepData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        context.delete(sleepData)
        commit()
    }
    
    //插入 sleepItem
    public func createSleepItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItemId itemId: Int16) -> SleepItem?{
        //判断sportItem是否存在
        var sleepItem = selectSleepItem(userId: id, withMacAddress: macAddress, withDate: date, withItemId: itemId)
        guard sleepItem == nil else {
            return sleepItem
        }
        
        //判断sportData是否存在
        guard let sleepData = selectSleepData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return nil
        }
        
        sleepItem = NSEntityDescription.insertNewObject(forEntityName: "SleepItem", into: context) as! SleepItem
        sleepItem?.id = itemId
        commit()
        
        sleepData.addToSleepItem(sleepItem!)
        
        guard commit() else {
            return nil
        }
        
        return sleepItem
    }
    
    //获取 sleepItem
    private func selectSleepItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItemId itemId: Int16) -> SleepItem?{
        
        let request: NSFetchRequest<SleepItem> = SleepItem.fetchRequest()
        let predicate = NSPredicate(format: "sleepData.macAddress = \(macAddress) AND sleepData.user.userId = \(id) AND sleepData.date = '\(date)' AND id = \(itemId)", "")
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
}

//MARK:- HeartRateData
extension CoreDataHandler{
    
    //插入 heartRateData
    public func insertHeartRateData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withItems items: [String: Any]? = nil) -> HeartRateData?{
        
        //判断当前日期heartRateData是否存在
        let heartRateDataList = selectHeartRateData(userId: id, withMacAddress: macAddress, withDate: date)
        guard heartRateDataList.isEmpty else {
            let sleepData = heartRateDataList.first
            if let dict = items{
                sleepData?.setValuesForKeys(dict)
            }
            commit()
            return heartRateDataList.first
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建运动数据模型
        let heartRateData = NSEntityDescription.insertNewObject(forEntityName: "HeartRateData", into: context) as! HeartRateData
        heartRateData.date = date as! NSDate
        
        if let dict = items{
            heartRateData.setValuesForKeys(dict)
        }
        commit()
        
        //为设备添加运动数据
        device.addToHeartRateDatas(heartRateData)
        guard commit() else {
            return nil
        }
        
        return heartRateData
    }
    
    //获取 heartRateData
    public func selectHeartRateData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withDayRange dayRange: Int = 0) -> [HeartRateData]{
        //根据用户设备列表获取设备
        let request: NSFetchRequest<HeartRateData> = HeartRateData.fetchRequest()
        let startDate = translate(date) as! NSDate
        let endDate = translate(date, withDayOffset: dayRange) as! NSDate
        let predicate = NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date >= '\(startDate)' AND date <= '\(endDate)'", "")
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            print(error)
        }
        return []
    }
    
    //更新 heartRateData
    public func updateHeartRateData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItems items: [String: Any]){
        guard let heartRateData = selectHeartRateData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        heartRateData.setValuesForKeys(items)
        commit()
    }
    
    //删除 heartRateData
    public func deleteHeartRateData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date){
        guard let heartRateData = selectHeartRateData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        context.delete(heartRateData)
        commit()
    }
    
    //插入 heartRateItem
    public func createHeartRateItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItemId itemId: Int16) -> HeartRateItem?{
        //判断sportItem是否存在
        var heartRateItem = selectHeartRateItem(userId: id, withMacAddress: macAddress, withDate: date, withItemId: itemId)
        guard heartRateItem == nil else {
            return heartRateItem
        }
        
        //判断sportData是否存在
        guard let heartRateData = selectHeartRateData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return nil
        }
        
        heartRateItem = NSEntityDescription.insertNewObject(forEntityName: "HeartRateItem", into: context) as! HeartRateItem
        heartRateItem?.id = itemId
        commit()
        
        heartRateData.addToHeartRateItem(heartRateItem!)
        
        guard commit() else {
            return nil
        }
        
        return heartRateItem
    }
    
    //获取 heartRateItem
    private func selectHeartRateItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItemId itemId: Int16) -> HeartRateItem?{
        
        let request: NSFetchRequest<HeartRateItem> = HeartRateItem.fetchRequest()
        let predicate = NSPredicate(format: "heartRateData.macAddress = \(macAddress) AND heartRateData.user.userId = \(id) AND heartRateData.date = '\(date)' AND id = \(itemId)", "")
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
}
