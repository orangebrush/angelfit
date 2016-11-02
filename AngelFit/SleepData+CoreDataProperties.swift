//
//  SleepData+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 02/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData

extension SleepData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepData> {
        return NSFetchRequest<SleepData>(entityName: "SleepData");
    }

    @NSManaged public var id: Int16
    @NSManaged public var date: NSDate?
    @NSManaged public var itemCount: Int16
    @NSManaged public var lightSleepCount: Int16
    @NSManaged public var deepSleepCount: Int16
    @NSManaged public var wakeCount: Int16
    @NSManaged public var totalMinute: Int16
    @NSManaged public var endDate: NSDate?
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
