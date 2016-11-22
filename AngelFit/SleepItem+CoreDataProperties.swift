//
//  SleepItem+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 22/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension SleepItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepItem> {
        return NSFetchRequest<SleepItem>(entityName: "SleepItem");
    }

    @NSManaged public var durations: Int16
    @NSManaged public var id: Int16
    @NSManaged public var sleepStatus: Int16
    @NSManaged public var sleepData: SleepData?

}
