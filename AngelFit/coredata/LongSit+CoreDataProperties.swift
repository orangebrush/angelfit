//
//  LongSit+CoreDataProperties.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/17.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension LongSit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LongSit> {
        return NSFetchRequest<LongSit>(entityName: "LongSit");
    }

    @NSManaged public var endDate: NSDate?
    @NSManaged public var interval: Int16
    @NSManaged public var repetitions: NSObject?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var isOpen: Bool

}
