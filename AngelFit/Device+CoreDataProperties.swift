//
//  Device+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 02/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData

extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device");
    }

    @NSManaged public var deviceId: Int16
    @NSManaged public var deviceUUID: String?
    @NSManaged public var macAddress: String?
    @NSManaged public var version: String?
    @NSManaged public var battStatus: String?
    @NSManaged public var model: String?
    @NSManaged public var battLevel: Int16
    @NSManaged public var pairFlag: String?
    @NSManaged public var rebootFlag: Int16
    @NSManaged public var type: Int16
    @NSManaged public var bandStatus: Int16
    @NSManaged public var user: User?
    @NSManaged public var lostFind: LostFind?
    @NSManaged public var longSit: LongSit?
    @NSManaged public var notice: Notice?
    @NSManaged public var unit: Unit?
    @NSManaged public var alarm: Alarm?
    @NSManaged public var handGesture: HandGesture?
    @NSManaged public var sportData: SportData?
    @NSManaged public var sleepData: SleepData?
    @NSManaged public var heartRateData: HeartRateData?

}
