//
//  User+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 21/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var birthday: NSDate?
    @NSManaged public var gender: Int16
    @NSManaged public var goalCal: Int16
    @NSManaged public var goalDistance: Int16
    @NSManaged public var goalSleep: Int16
    @NSManaged public var goalStep: Int16
    @NSManaged public var height: Int16
    @NSManaged public var userId: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var devices: NSSet?

}

// MARK: Generated accessors for devices
extension User {

    @objc(addDevicesObject:)
    @NSManaged public func addToDevices(_ value: Device)

    @objc(removeDevicesObject:)
    @NSManaged public func removeFromDevices(_ value: Device)

    @objc(addDevices:)
    @NSManaged public func addToDevices(_ values: NSSet)

    @objc(removeDevices:)
    @NSManaged public func removeFromDevices(_ values: NSSet)

}
