//
//  Device+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 23/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device");
    }

    @NSManaged public var bandStatus: Int16
    @NSManaged public var battLevel: Int16
    @NSManaged public var battStatus: Int16
    @NSManaged public var deviceId: Int16
    @NSManaged public var deviceUUID: String?
    @NSManaged public var findPhoneSwitch: Bool
    @NSManaged public var macAddress: String?
    @NSManaged public var mode: Int16
    @NSManaged public var pairFlag: Bool
    @NSManaged public var rebootFlag: Bool
    @NSManaged public var sos: Bool
    @NSManaged public var type: Int16
    @NSManaged public var version: Int16
    @NSManaged public var landscape: Bool
    @NSManaged public var alarms: NSOrderedSet?
    @NSManaged public var handGesture: HandGesture?
    @NSManaged public var heartRateDatas: NSSet?
    @NSManaged public var longSit: LongSit?
    @NSManaged public var lostFind: LostFind?
    @NSManaged public var notice: Notice?
    @NSManaged public var silentDistrube: SilentDistrube?
    @NSManaged public var sleepDatas: NSSet?
    @NSManaged public var sportDatas: NSSet?
    @NSManaged public var unit: Unit?
    @NSManaged public var user: User?
    @NSManaged public var heartInterval: HeartInterval?
    @NSManaged public var funcTable: FuncTable?

}

// MARK: Generated accessors for alarms
extension Device {

    @objc(insertObject:inAlarmsAtIndex:)
    @NSManaged public func insertIntoAlarms(_ value: Alarm, at idx: Int)

    @objc(removeObjectFromAlarmsAtIndex:)
    @NSManaged public func removeFromAlarms(at idx: Int)

    @objc(insertAlarms:atIndexes:)
    @NSManaged public func insertIntoAlarms(_ values: [Alarm], at indexes: NSIndexSet)

    @objc(removeAlarmsAtIndexes:)
    @NSManaged public func removeFromAlarms(at indexes: NSIndexSet)

    @objc(replaceObjectInAlarmsAtIndex:withObject:)
    @NSManaged public func replaceAlarms(at idx: Int, with value: Alarm)

    @objc(replaceAlarmsAtIndexes:withAlarms:)
    @NSManaged public func replaceAlarms(at indexes: NSIndexSet, with values: [Alarm])

    @objc(addAlarmsObject:)
    @NSManaged public func addToAlarms(_ value: Alarm)

    @objc(removeAlarmsObject:)
    @NSManaged public func removeFromAlarms(_ value: Alarm)

    @objc(addAlarms:)
    @NSManaged public func addToAlarms(_ values: NSOrderedSet)

    @objc(removeAlarms:)
    @NSManaged public func removeFromAlarms(_ values: NSOrderedSet)

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
