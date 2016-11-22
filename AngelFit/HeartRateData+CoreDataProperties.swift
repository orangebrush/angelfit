//
//  HeartRateData+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 22/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension HeartRateData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HeartRateData> {
        return NSFetchRequest<HeartRateData>(entityName: "HeartRateData");
    }

    @NSManaged public var aerobicMinutes: Int16
    @NSManaged public var aerobicThreshold: Int16
    @NSManaged public var burnFatMinutes: Int16
    @NSManaged public var burnFatThreshold: Int16
    @NSManaged public var date: NSDate?
    @NSManaged public var id: Int16
    @NSManaged public var itemCount: Int16
    @NSManaged public var limitMinutes: Int16
    @NSManaged public var limitThreshold: Int16
    @NSManaged public var minuteOffset: Int16
    @NSManaged public var silentHeartRate: Int16
    @NSManaged public var packetsCount: Int16
    @NSManaged public var device: Device?
    @NSManaged public var heartRateItem: NSSet?

}

// MARK: Generated accessors for heartRateItem
extension HeartRateData {

    @objc(addHeartRateItemObject:)
    @NSManaged public func addToHeartRateItem(_ value: HeartRateItem)

    @objc(removeHeartRateItemObject:)
    @NSManaged public func removeFromHeartRateItem(_ value: HeartRateItem)

    @objc(addHeartRateItem:)
    @NSManaged public func addToHeartRateItem(_ values: NSSet)

    @objc(removeHeartRateItem:)
    @NSManaged public func removeFromHeartRateItem(_ values: NSSet)

}
