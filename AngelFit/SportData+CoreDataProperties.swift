//
//  SportData+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 21/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension SportData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SportData> {
        return NSFetchRequest<SportData>(entityName: "SportData");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: Int16
    @NSManaged public var itemCount: Int16
    @NSManaged public var minuteDuration: Int16
    @NSManaged public var minuteOffset: Int16
    @NSManaged public var totalActiveTime: Int16
    @NSManaged public var totalCal: Int16
    @NSManaged public var totalDistance: Int16
    @NSManaged public var device: Device?
    @NSManaged public var sportItem: NSSet?

}

// MARK: Generated accessors for sportItem
extension SportData {

    @objc(addSportItemObject:)
    @NSManaged public func addToSportItem(_ value: SportItem)

    @objc(removeSportItemObject:)
    @NSManaged public func removeFromSportItem(_ value: SportItem)

    @objc(addSportItem:)
    @NSManaged public func addToSportItem(_ values: NSSet)

    @objc(removeSportItem:)
    @NSManaged public func removeFromSportItem(_ values: NSSet)

}
