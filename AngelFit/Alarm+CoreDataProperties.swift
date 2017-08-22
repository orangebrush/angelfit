//
//  Alarm+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 25/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension Alarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Alarm> {
        return NSFetchRequest<Alarm>(entityName: "Alarm");
    }

    @NSManaged public var duration: Int16
    @NSManaged public var hour: Int16
    @NSManaged public var id: Int16
    @NSManaged public var minute: Int16
    @NSManaged public var repeatList: Int16
    @NSManaged public var status: Int16
    @NSManaged public var synchronize: Bool
    @NSManaged public var type: Int16
    @NSManaged public var device: Device?

}
