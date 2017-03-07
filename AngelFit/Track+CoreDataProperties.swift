//
//  Track+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2017/3/7.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track");
    }

    @NSManaged public var aerobicMinutes: Int16
    @NSManaged public var avgrageHeartrate: Int16
    @NSManaged public var burnFatMinutes: Int16
    @NSManaged public var calories: Int16
    @NSManaged public var coordinateList: NSArray?
    @NSManaged public var date: NSDate?
    @NSManaged public var distance: Int16
    @NSManaged public var durations: Int16
    @NSManaged public var heartrateList: NSArray?
    @NSManaged public var limitMinutes: Int16
    @NSManaged public var maxHeartrate: Int16
    @NSManaged public var serial: Int16
    @NSManaged public var step: Int16
    @NSManaged public var type: Int16
    @NSManaged public var device: Device?

}
