//
//  Notice+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 22/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension Notice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notice> {
        return NSFetchRequest<Notice>(entityName: "Notice");
    }

    @NSManaged public var callDelay: Int16
    @NSManaged public var callSwitch: Bool
    @NSManaged public var notifyItem0: Int16
    @NSManaged public var notifySwitch: Bool
    @NSManaged public var notifyItem1: Int16
    @NSManaged public var musicSwitch: Bool

}
