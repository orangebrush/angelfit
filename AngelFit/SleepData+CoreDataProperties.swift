//
//  SleepData+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 22/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension SleepData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepData> {
        return NSFetchRequest<SleepData>(entityName: "SleepData");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var deepSleepCount: Int16
    @NSManaged public var id: Int16
    @NSManaged public var sleepItemCount: Int16
    @NSManaged public var lightSleepCount: Int16
    @NSManaged public var totalMinute: Int16
    @NSManaged public var wakeCount: Int16
    @NSManaged public var endTimeHour: Int16
    @NSManaged public var endTimeMinute: Int16
    @NSManaged public var startTimeHour: Int16
    @NSManaged public var startTimeMinute: Int16
    @NSManaged public var serial: Int16
    @NSManaged public var packetCount: Int16
    @NSManaged public var lightSleepMinute: Int16
    @NSManaged public var deepSleepMinute: Int16
    @NSManaged public var itemsCount: Int16
    @NSManaged public var device: Device?
    @NSManaged public var sleepItem: NSSet?

}

// MARK: Generated accessors for sleepItem
extension SleepData {

    @objc(addSleepItemObject:)
    @NSManaged public func addToSleepItem(_ value: SleepItem)

    @objc(removeSleepItemObject:)
    @NSManaged public func removeFromSleepItem(_ value: SleepItem)

    @objc(addSleepItem:)
    @NSManaged public func addToSleepItem(_ values: NSSet)

    @objc(removeSleepItem:)
    @NSManaged public func removeFromSleepItem(_ values: NSSet)

}
