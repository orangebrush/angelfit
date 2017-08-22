//
//  LongSit+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 21/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension LongSit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LongSit> {
        return NSFetchRequest<LongSit>(entityName: "LongSit");
    }

    @NSManaged public var endDate: NSDate?
    @NSManaged public var interval: Int16
    @NSManaged public var isOpen: Bool
    @NSManaged public var startDate: NSDate?
    @NSManaged public var weekdayList: NSObject?

}
