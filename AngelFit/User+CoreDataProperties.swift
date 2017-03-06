//
//  User+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2017/3/6.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
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
    @NSManaged public var goalStep: Int16
    @NSManaged public var height: Int16
    @NSManaged public var userId: Int16
    @NSManaged public var goalWeight: Float
    @NSManaged public var sleepHour: Int16
    @NSManaged public var sleepMinute: Int16
    @NSManaged public var wakeHour: Int16
    @NSManaged public var wakeMinute: Int16
    @NSManaged public var currentWeight: Float
    @NSManaged public var devices: NSSet?
    @NSManaged public var weights: NSSet?

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

// MARK: Generated accessors for weights
extension User {

    @objc(addWeightsObject:)
    @NSManaged public func addToWeights(_ value: Weight)

    @objc(removeWeightsObject:)
    @NSManaged public func removeFromWeights(_ value: Weight)

    @objc(addWeights:)
    @NSManaged public func addToWeights(_ values: NSSet)

    @objc(removeWeights:)
    @NSManaged public func removeFromWeights(_ values: NSSet)

}
