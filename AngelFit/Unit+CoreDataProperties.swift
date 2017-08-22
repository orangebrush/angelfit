//
//  Unit+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 21/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension Unit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Unit> {
        return NSFetchRequest<Unit>(entityName: "Unit");
    }

    @NSManaged public var distance: Int16
    @NSManaged public var language: Int16
    @NSManaged public var stride: Int16
    @NSManaged public var temperature: Int16
    @NSManaged public var timeFormat: Int16
    @NSManaged public var weight: Int16

}
