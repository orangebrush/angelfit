//
//  SilentDistrube+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 21/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension SilentDistrube {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SilentDistrube> {
        return NSFetchRequest<SilentDistrube>(entityName: "SilentDistrube");
    }

    @NSManaged public var endHour: Int16
    @NSManaged public var endMinute: Int16
    @NSManaged public var isOpen: Bool
    @NSManaged public var startHour: Int16
    @NSManaged public var startMinute: Int16

}
