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
            if resultList.isEmpty {
                fatalError("<Core Data> delete not exist result")
            }else{
                
                context.delete(resultList[0])
                guard commit() else{
                    return
                }
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

//MARK:- User
extension CoreDataHandler{

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
                guard commit() else{
                    return nil
                }
            }
            return device
        }
        
        //判断是否有用户
        guard let user = selectUser(userId: id) else{
            return nil
        }
        
        //创建设备模型
        device = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context) as? Device
        device?.macAddress = macAddress
        device?.landscape = true
        
        if let dict = items {
            device?.setValuesForKeys(dict)
        }
        guard commit() else{
            return nil
        }
        
        //为用户添加设备
        user.addToDevices(device!)
        guard commit() else {
            return nil
        }
        
        //初始化设备信息
        _ = insertUnit(userId: id, withMacAddress: macAddress, withItems: nil)
        _ = insertLongSit(userId: id, withMacAddress: macAddress, withItems: nil)
        _ = insertNotice(userId: id, withMacAddress: macAddress, withItems: nil)
        _ = insertHandGesture(userId: id, withMacAddress: macAddress, withItems: nil)
        _ = insertLostFind(userId: id, withMacAddress: macAddress, withItems: nil)
        _ = insertSilent(userId: id, withMacAddress: macAddress, withItems: nil)
        _ = insertHeartInterval(userId: id, withMacAddress: macAddress, withItems: nil)
        _ = insertFuncTable(userId: id, withMacAddress: macAddress, withItems: nil)
        
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
        longSit = NSEntityDescription.insertNewObject(forEntityName: "LongSit", into: context) as? LongSit
        
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
        guard commit() else{
            return
        }
    }
    
    //删除 longSit
    public func deleteLongSit(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let longSit = selectLongSit(userID: id, withMacAddress: macAddress) else {
            return
        }
        
        context.delete(longSit)
        guard commit() else{
            return
        }
    }
}

//MARK:- FuncTable
extension CoreDataHandler{
    //插入 funcTable
    public func insertFuncTable(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> FuncTable?{
        
        //判断funcTable是否存在
        var funcTable = selectFuncTable(userID: id, withMacAddress: macAddress)
        guard funcTable == nil else {
            if let dict = items {
                funcTable?.setValuesForKeys(dict)
            }
            guard commit() else{
                return nil
            }
            return funcTable
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建久坐数据模型
        funcTable = NSEntityDescription.insertNewObject(forEntityName: "FuncTable", into: context) as? FuncTable
        
        if let dict = items {
            funcTable?.setValuesForKeys(dict)
        }
        guard commit() else{
            return nil
        }
        
        //为设备添加久坐数据
        device.funcTable = funcTable
        
        guard commit() else{
            return nil
        }
        return funcTable
    }
    
    //获取 funcTable
    public func selectFuncTable(userID id: Int16 = 1, withMacAddress macAddress: String) -> FuncTable?{
        //根据设备获取久坐模型
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else{
            return nil
        }
        
        return device.funcTable
    }
    
    //更新 funcTable
    public func updateFuncTable(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        guard let funcTable = selectFuncTable(userID: id, withMacAddress: macAddress) else{
            return
        }
        funcTable.setValuesForKeys(items)
        guard commit() else{
            return
        }
    }
    
    //删除 funcTable
    public func deleteFuncTable(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let funcTable = selectFuncTable(userID: id, withMacAddress: macAddress) else {
            return
        }
        
        context.delete(funcTable)
        guard commit() else{
            return
        }
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
            guard commit() else{
                return nil
            }
            return notice
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建消息提醒模型
        notice = NSEntityDescription.insertNewObject(forEntityName: "Notice", into: context) as? Notice
        
        if let dict = items{
            notice?.setValuesForKeys(dict)
        }
        guard commit() else{
            return nil
        }
        
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
        guard commit() else{
            return
        }
    }
    
    //删除 notice
    public func deleteNotice(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let notice = selectNotice(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(notice)
        guard commit() else{
            return
        }
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
            guard commit() else{
                return nil
            }
            return unit
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        unit = NSEntityDescription.insertNewObject(forEntityName: "Unit", into: context) as? Unit
        unit?.distance = 0x01
        unit?.weight = 0x01
        unit?.temperature = 0x01
        unit?.stride = 70 //默认步长=70cm
        unit?.language = 0x01
        unit?.timeFormat = 0x01
        
        if let dict = items{
            unit?.setValuesForKeys(dict)
        }
        guard commit() else{
            return nil
        }
        
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
        _ = commit()
    }
    
    //删除 unit
    public func deleteUnit(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let unit = selectUnit(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(unit)
        _ = commit()
    }
}

//MARK:- SilentDistrube
extension CoreDataHandler{
    //插入 silentDistrube
    public func insertSilent(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> SilentDistrube?{
        
        //判断silentMode是否存在
        var silentDistrube = selectSilentDistrube(userId: id, withMacAddress: macAddress)
        guard silentDistrube == nil else {
            if let dict = items{
                silentDistrube?.setValuesForKeys(dict)
                guard commit() else{
                    return nil
                }
            }
            return silentDistrube
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        silentDistrube = NSEntityDescription.insertNewObject(forEntityName: "SilentDistrube", into: context) as? SilentDistrube
        silentDistrube?.isOpen = false
        silentDistrube?.startHour = 0
        silentDistrube?.startMinute = 0
        silentDistrube?.endHour = 0
        silentDistrube?.endMinute = 0
        
        if let dict = items{
            silentDistrube?.setValuesForKeys(dict)
        }
        guard commit() else {
            return nil
        }
        
        //为设备添加单位数据
        device.silentDistrube = silentDistrube
        guard commit() else {
            return nil
        }
        return silentDistrube
    }
    
    //获取 unit
    public func selectSilentDistrube(userId id: Int16 = 1, withMacAddress macAddress: String) -> SilentDistrube?{
        //根据设备获取单位模型
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        return device.silentDistrube
    }
    
    //更新 unit
    public func updateSilentDistrube(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        guard let silentDistrube = selectSilentDistrube(userId: id, withMacAddress: macAddress) else {
            return
        }
        silentDistrube.setValuesForKeys(items)
        _ = commit()
    }
    
    //删除 unit
    public func deleteSilentDistrube(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let silentDistrube = selectSilentDistrube(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(silentDistrube)
        _ = commit()
    }
}

//MARK:- HeartInterval
extension CoreDataHandler{
    //插入 heartInterval
    public func insertHeartInterval(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> HeartInterval?{
        
        //判断heartInterval是否存在
        var heartInterval = selectHeartInterval(userId: id, withMacAddress: macAddress)
        guard heartInterval == nil else {
            if let dict = items{
                heartInterval?.setValuesForKeys(dict)
                guard commit() else{
                    return nil
                }
            }
            return heartInterval
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        heartInterval = NSEntityDescription.insertNewObject(forEntityName: "HeartInterval", into: context) as? HeartInterval
        heartInterval?.aerobic = 96     //1~255
        heartInterval?.burnFat = 135    //1~255
        heartInterval?.limit = 160      //1~255
        heartInterval?.heartRateMode = 0x88 //默认为自动模式 auto:0x88 close:0x55 manual:0xAA
        
        if let dict = items{
            heartInterval?.setValuesForKeys(dict)
        }
        guard commit() else {
            return nil
        }
        
        //为设备添加单位数据
        device.heartInterval = heartInterval
        guard commit() else {
            return nil
        }
        return heartInterval
    }
    
    //获取 heartInterval
    public func selectHeartInterval(userId id: Int16 = 1, withMacAddress macAddress: String) -> HeartInterval?{
        //根据设备获取单位模型
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        return device.heartInterval
    }
    
    //更新 heartInterval
    public func updateHeartInterval(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]){
        guard let heartInterval = selectHeartInterval(userId: id, withMacAddress: macAddress) else {
            return
        }
        heartInterval.setValuesForKeys(items)
        _ = commit()
    }
    
    //删除 heartInterval
    public func deleteHeartInterval(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let heartInterval = selectHeartInterval(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(heartInterval)
        _ = commit()
    }
}

//MARK:- Alarm
extension CoreDataHandler{
    //插入 alarm
    public func insertAlarm(userId id: Int16 = 1, withMacAddress macAddress: String, withItems items: [String: Any]? = nil) -> Alarm?{
        
        let oldAlarms = selectAllAlarm(userId: id, withMacAddress: macAddress)
        var ids = [Int16]()
        oldAlarms.forEach(){
            alarm in
            ids.append(alarm.id)
        }
        
        let alarmId: Int16 = ids.isEmpty ? 1 : (ids.max()! + 1)
        debug("alarmId:", alarmId)
        //判断alarm是否存在
        var alarms = selectAlarm(userId: id, alarmId: alarmId, withMacAddress: macAddress)
        debug("alarms:", alarms)
        guard alarms.isEmpty else {
            if let dict = items{
                alarms[0].setValuesForKeys(dict)
                guard commit() else{
                    return nil
                }
            }
            return alarms[0]
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        debug("device:", device)
        guard let newAlarm = NSEntityDescription.insertNewObject(forEntityName: "Alarm", into: context) as? Alarm else{
            return nil
        }
        
        //设置默认值
        newAlarm.duration = 0
        newAlarm.hour = 0
        newAlarm.minute = 0
        newAlarm.id = alarmId
        newAlarm.status = 0x55
        newAlarm.type = 0x07
        newAlarm.synchronize = false
        newAlarm.repeatList = 0
        
        if let dict = items{
            newAlarm.setValuesForKeys(dict)
        }
        debug("newAlarm:", newAlarm)
        guard commit() else{
            return nil
        }
        
        
        //为设备添加闹钟数据
        device.addToAlarms(newAlarm)
        guard commit() else {
            return nil
        }
        return newAlarm
    }
    
    //获取 alarm
    public func selectAlarm(userId id: Int16 = 1, alarmId: Int16, withMacAddress macAddress: String) -> [Alarm]{
        //根据设备获取闹钟模型
        guard (selectDevice(userId: id, withMacAddress: macAddress) != nil) else {
            return []
        }
        
        let request: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        let predicate = NSPredicate(format: "id = \(id)", "")
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            print(error)
        }
        return []
    }
    
    //获取所有 alarm
    public func selectAllAlarm(userId id: Int16 = 1, withMacAddress macAddress: String) -> [Alarm]{
        //根据设备获取闹钟模型
        
        let request: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        let predicate = NSPredicate(format: "device.macAddress = '\(macAddress)' AND device.user.userId = \(id)")
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            if resultList.isEmpty {
                return []
            }else{
                return resultList
            }
        }catch let error{
            print(error)
        }
        return []
    }
    
    //删除 alarm
    public func deleteAlarm(userId id: Int16 = 1, alarmId: Int16, withMacAddress macAddress: String){
        let alarmList = selectAlarm(userId: id, alarmId: alarmId, withMacAddress: macAddress)
        guard !alarmList.isEmpty else {
            return
        }
        
        context.delete(alarmList[0])
        guard commit() else{
            return
        }
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
            guard commit() else{
                return nil
            }
            return handGesture
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        handGesture = NSEntityDescription.insertNewObject(forEntityName: "HandGesture", into: context) as? HandGesture
        handGesture?.displayTime = 3
        handGesture?.isOpen = true
        if let dict = items {
            handGesture?.setValuesForKeys(dict)
        }
        guard commit() else{
            return nil
        }
        
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
        guard commit() else{
            return
        }
    }
    
    //删除 handGesture
    public func deleteHandGesture(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let handGesture = selectHandGesture(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(handGesture)
        guard commit() else{
            return
        }
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
            guard commit() else{
                return nil
            }
            return lostFind
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        lostFind = NSEntityDescription.insertNewObject(forEntityName: "LostFind", into: context) as? LostFind
        
        if let dict = items{
            lostFind?.setValuesForKeys(dict)
        }
        guard commit() else{
            return nil
        }
        
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
        guard commit() else{
            return
        }
    }
    
    //删除 lostFind
    public func deleteLostFind(userId id: Int16 = 1, withMacAddress macAddress: String){
        guard let lostFind = selectLostFind(userId: id, withMacAddress: macAddress) else {
            return
        }
        context.delete(lostFind)
        guard commit() else{
            return
        }
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
                guard commit() else{
                    return nil
                }
            }
            return sportDataList.first
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建运动数据模型
        let sportData = NSEntityDescription.insertNewObject(forEntityName: "SportData", into: context) as! SportData
        sportData.date = date as NSDate
        
        if let dict = items{
            sportData.setValuesForKeys(dict)
        }
        
        //为设备添加运动数据
        device.addToSportDatas(sportData)
        guard commit() else {
            return nil
        }
        
        return sportData
    }
    
    //获取 sportData
    public func selectSportData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withDayRange dayRange: Int = 0) -> [SportData]{
        pthread_mutex_lock(&CoreDataHandler.rwlock)
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<SportData> = SportData.fetchRequest()
        let startDate = translate(date) //as NSDate
        let endDate = translate(date, withDayOffset: dayRange) //as NSDate
        let predicate = NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            pthread_mutex_unlock(&CoreDataHandler.rwlock)
            return resultList
        }catch let error{
            pthread_mutex_unlock(&CoreDataHandler.rwlock)
            print(error)
        }
        pthread_mutex_unlock(&CoreDataHandler.rwlock)
        return []
    }
    
    //更新 sportData
    public func updateSportData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItems items: [String: Any]){
        guard let sportData = selectSportData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        sportData.setValuesForKeys(items)
        guard commit() else{
            return
        }
    }
    
    //删除 sportData
    public func deleteSportData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date){
        guard let sportData = selectSportData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        context.delete(sportData)
        guard commit() else{
            return
        }
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
        
        sportItem = NSEntityDescription.insertNewObject(forEntityName: "SportItem", into: context) as? SportItem
        sportItem?.id = itemId
        
        sportData.addToSportItem(sportItem!)
        
        guard commit() else {
            return nil
        }
        
        return sportItem
    }
    
    //获取 sportItem
    private func selectSportItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItemId itemId: Int16) -> SportItem?{
        
        let request: NSFetchRequest<SportItem> = SportItem.fetchRequest()
        let predicate = NSPredicate(format: "sportData.device.macAddress = '\(macAddress)' AND sportData.device.user.userId = \(id) AND sportData.date = %@ AND id = \(itemId)", translate(date) as! CVarArg)
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
                guard commit() else{
                    return nil
                }
            }
            return sleepDataList.first
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建运动数据模型
        let sleepData = NSEntityDescription.insertNewObject(forEntityName: "SleepData", into: context) as! SleepData
        sleepData.date = date as NSDate
        
        if let dict = items{
            sleepData.setValuesForKeys(dict)
        }
        
        //为设备添加运动数据
        device.addToSleepDatas(sleepData)
        guard commit() else {
            return nil
        }
        
        return sleepData
    }
    
    //获取 sleepData
    public func selectSleepData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withDayRange dayRange: Int = 0) -> [SleepData]{
        
        pthread_mutex_lock(&CoreDataHandler.rwlock)
        //根据用户设备列表获取设备
        let request: NSFetchRequest<SleepData> = SleepData.fetchRequest()
        let startDate = translate(date)
        let endDate = translate(date, withDayOffset: dayRange)
        let predicate = NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            pthread_mutex_unlock(&CoreDataHandler.rwlock)
            return resultList
        }catch let error{
            pthread_mutex_unlock(&CoreDataHandler.rwlock)
            print(error)
        }
        pthread_mutex_unlock(&CoreDataHandler.rwlock)
        return []
    }
    
    //更新 sleepData
    public func updateSleepData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItems items: [String: Any]){
        guard let sleepData = selectSleepData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        sleepData.setValuesForKeys(items)
        guard commit() else{
            return
        }
    }
    
    //删除 sleepData
    public func deleteSleepData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date){
        guard let sleepData = selectSleepData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        context.delete(sleepData)
        guard commit() else{
            return
        }
    }
    
    //插入 sleepItem @params: itemId: 详细数据index
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
        
        sleepItem = NSEntityDescription.insertNewObject(forEntityName: "SleepItem", into: context) as? SleepItem
        sleepItem?.id = itemId
        
        sleepData.addToSleepItem(sleepItem!)
        
        guard commit() else {
            return nil
        }
        
        return sleepItem
    }
    
    //获取 sleepItem
    private func selectSleepItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItemId itemId: Int16) -> SleepItem?{
        
        let request: NSFetchRequest<SleepItem> = SleepItem.fetchRequest()
        let predicate = NSPredicate(format: "sleepData.device.macAddress = '\(macAddress)' AND sleepData.device.user.userId = \(id) AND sleepData.date = %@ AND id = \(itemId)", translate(date) as! CVarArg)
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
            let heartRateData = heartRateDataList.first
            if let dict = items{
                heartRateData?.setValuesForKeys(dict)
                guard commit() else{
                    return nil
                }
            }
            return heartRateDataList.first
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建运动数据模型
        let heartRateData = NSEntityDescription.insertNewObject(forEntityName: "HeartRateData", into: context) as! HeartRateData
        heartRateData.date = date as NSDate
        
        if let dict = items{
            heartRateData.setValuesForKeys(dict)
        }
        
        //为设备添加运动数据
        device.addToHeartRateDatas(heartRateData)
        guard commit() else {
            return nil
        }
        
        return heartRateData
    }
    
    //获取 heartRateData
    public func selectHeartRateData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withDayRange dayRange: Int = 0) -> [HeartRateData]{
        
        pthread_mutex_lock(&CoreDataHandler.rwlock)
        
        //根据用户设备列表获取设备
        let request: NSFetchRequest<HeartRateData> = HeartRateData.fetchRequest()
        let startDate = translate(date)
        let endDate = translate(date, withDayOffset: dayRange)
        let predicate = NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date >= %@ AND date <= %@", startDate as! CVarArg, endDate as! CVarArg)
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            pthread_mutex_unlock(&CoreDataHandler.rwlock)
            return resultList
        }catch let error{
            print(error)
        }
        
        pthread_mutex_unlock(&CoreDataHandler.rwlock)
        return []
    }
    
    //更新 heartRateData
    public func updateHeartRateData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItems items: [String: Any]){
        guard let heartRateData = selectHeartRateData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        heartRateData.setValuesForKeys(items)
        guard commit() else{
            return
        }
    }
    
    //删除 heartRateData
    public func deleteHeartRateData(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date){
        guard let heartRateData = selectHeartRateData(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        context.delete(heartRateData)
        guard commit() else{
            return
        }
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
        
        heartRateItem = NSEntityDescription.insertNewObject(forEntityName: "HeartRateItem", into: context) as? HeartRateItem
        heartRateItem?.id = itemId
        
        
        heartRateData.addToHeartRateItem(heartRateItem!)
        
        guard commit() else {
            return nil
        }
        
        return heartRateItem
    }
    
    //获取 heartRateItem
    private func selectHeartRateItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItemId itemId: Int16) -> HeartRateItem?{
        
        let request: NSFetchRequest<HeartRateItem> = HeartRateItem.fetchRequest()
        let predicate = NSPredicate(format: "heartRateData.device.macAddress = '\(macAddress)' AND heartRateData.device.user.userId = \(id) AND heartRateData.date = %@ AND id = \(itemId)", translate(date) as! CVarArg)
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

//MARK:- Trucks
extension CoreDataHandler{
    //插入 Track
    public func insertTrack(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withItems items: [String: Any]? = nil) -> Track?{
        
        //判断当前日期heartRateData是否存在
        let trackList = selectTrack(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: nil)
        guard trackList.isEmpty else {
            let track = trackList.first
            if let dict = items{
                track?.setValuesForKeys(dict)
            }
            guard commit() else{
                return nil
            }
            return trackList.first
        }
        
        //判断设备是否存在
        guard let device = selectDevice(userId: id, withMacAddress: macAddress) else {
            return nil
        }
        
        //创建运动数据模型
        let track = NSEntityDescription.insertNewObject(forEntityName: "Track", into: context) as! Track
        track.date = translate(date) as NSDate
        
        if let dict = items{
            track.setValuesForKeys(dict)
        }
        
        //为设备添加运动数据
        device.addToTracks(track)
        guard commit() else {
            return nil
        }
        
        return track
    }
    
    //获取 Track   dayRange置空则获取准确数据
    public func selectTrack(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withDayRange dayRange: Int? = 0) -> [Track]{
        pthread_mutex_lock(&CoreDataHandler.rwlock)
        //根据用户设备列表获取设备
        let request: NSFetchRequest<Track> = Track.fetchRequest()
        let startDate = translate(date)
        let endDate = translate(date, withDayOffset: dayRange == nil ? 0 : dayRange! + 1)       //+1偏移日期 第二天0点
        let predicate = dayRange == nil ?
            NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date == %@", date as CVarArg) :
            NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        request.predicate = predicate
        do{
            let resultList = try context.fetch(request)
            pthread_mutex_unlock(&CoreDataHandler.rwlock)
            return resultList
        }catch let error{
            print(error)
        }
        pthread_mutex_unlock(&CoreDataHandler.rwlock)
        return []
    }
    
    //获取 trackList 个数
    public func selectTrackCount(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date = Date(), withDayRange dayRange: Int = 0) -> Int{
        //根据用户设备列表获取设备
        let request: NSFetchRequest<Track> = Track.fetchRequest()
        let startDate = translate(date)
        let endDate = translate(date, withDayOffset: dayRange)
        let predicate = dayRange == 0 ? NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date == %@", date as! CVarArg) : NSPredicate(format: "device.user.userId = \(id) AND device.macAddress = '\(macAddress)' AND date >= %@ AND date <= %@", startDate as! CVarArg, endDate as! CVarArg)
        request.predicate = predicate
        do{
            let count = try context.count(for: request)
            return count
        }catch let error{
            print(error)
        }
        return 0
    }
    
    //更新 Track
    public func updateTrack(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withItems items: [String: Any]){
        guard let track = selectTrack(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: 0).first else {
            return
        }
        track.setValuesForKeys(items)
        guard commit() else{
            return
        }
    }
    
    //删除 Track
    public func deleteTrack(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date){
        guard let track = selectTrack(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: nil).last else {
            return
        }
        context.delete(track)
        guard commit() else{
            return
        }
    }
    
    //插入 trackItem
    public func createTrackItem(userId id: Int16 = 1, withMacAddress macAddress: String, withDate date: Date, withTotalDistance distance: Double, withCoordinate coordinate: CLLocationCoordinate2D, interval: TimeInterval, childDistance subDistance: Double) -> TrackItem?{
        
        //判断track是否存在
        guard let track = selectTrack(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: nil).first else {
            return nil
        }
        
        track.distance = distance
        
        let trackItem = NSEntityDescription.insertNewObject(forEntityName: "TrackItem", into: context) as? TrackItem
        trackItem?.date = Date() as NSDate?
        trackItem?.subDistance = subDistance
        trackItem?.interval = interval
        trackItem?.longtitude = coordinate.longitude
        trackItem?.latitude = coordinate.latitude
        
        track.addToTrackItems(trackItem!)
        
        guard commit() else {
            return nil
        }
        
        return trackItem
    }
    
    //插入 trackHeartrateItem
    public func createTrackHeartrateItem(userId id: Int16 = 1, withMacAaddress macAddress: String, withDate date: Date, withHeartrateId heartrateId: Int16, withOffset offset: Int16, withData data: Int16) -> TrackHeartrateItem?{
        //判断track是否存在
        guard let track = selectTrack(userId: id, withMacAddress: macAddress, withDate: date, withDayRange: nil).first else {
            return nil
        }
        
        let trackHeartrateItem = NSEntityDescription.insertNewObject(forEntityName: "TrackHeartrateItem", into: context) as? TrackHeartrateItem
        
        trackHeartrateItem?.data = data
        trackHeartrateItem?.id = heartrateId
        trackHeartrateItem?.offset = offset     //暂无用 5s一次
        
        track.addToTrackHeartrateItems(trackHeartrateItem!)
        
        guard commit() else {
            return nil
        }
        
        return trackHeartrateItem
    }
}
