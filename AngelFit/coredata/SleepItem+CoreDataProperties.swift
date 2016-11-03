//
//  SleepItem+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
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
