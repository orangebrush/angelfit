//
//  Device+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData

extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device");
    }

    @NSManaged public var bandStatus: Int16
    @NSManaged public var battLevel: Int16
    @NSManaged public var battStatus: String?
    @NSManaged public var deviceId: Int16
    @NSManaged public var deviceUUID: String?
    @NSManaged public var macAddress: String?
    @NSManaged public var model: String?
    @NSManaged public var pairFlag: String?
    @NSManaged public var rebootFlag: Int16
    @NSManaged public var type: Int16
    @NSManaged public var version: String?
    @NSManaged public var alarm: Alarm?
    @NSManaged public var handGesture: HandGesture?
    @NSManaged public var heartRateDatas: NSSet?
    @NSManaged public var longSit: LongSit?
    @NSManaged public var lostFind: LostFind?
    @NSManaged public var notice: Notice?
    @NSManaged public var sleepDatas: NSSet?
    @NSManaged public var sportDatas: NSSet?
    @NSManaged public var unit: Unit?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for heartRateDatas
extension Device {

    @objc(addHeartRateDatasObject:)
    @NSManaged public func addToHeartRateDatas(_ value: HeartRateData)

    @objc(removeHeartRateDatasObject:)
    @NSManaged public func removeFromHeartRateDatas(_ value: HeartRateData)

    @objc(addHeartRateDatas:)
    @NSManaged public func addToHeartRateDatas(_ values: NSSet)

    @objc(removeHeartRateDatas:)
    @NSManaged public func removeFromHeartRateDatas(_ values: NSSet)

}

// MARK: Generated accessors for sleepDatas
extension Device {

    @objc(addSleepDatasObject:)
    @NSManaged public func addToSleepDatas(_ value: SleepData)

    @objc(removeSleepDatasObject:)
    @NSManaged public func removeFromSleepDatas(_ value: SleepData)

    @objc(addSleepDatas:)
    @NSManaged public func addToSleepDatas(_ values: NSSet)

    @objc(removeSleepDatas:)
    @NSManaged public func removeFromSleepDatas(_ values: NSSet)

}

// MARK: Generated accessors for sportDatas
extension Device {

    @objc(addSportDatasObject:)
    @NSManaged public func addToSportDatas(_ value: SportData)

    @objc(removeSportDatasObject:)
    @NSManaged public func removeFromSportDatas(_ value: SportData)

    @objc(addSportDatas:)
    @NSManaged public func addToSportDatas(_ values: NSSet)

    @objc(removeSportDatas:)
    @NSManaged public func removeFromSportDatas(_ values: NSSet)

}
