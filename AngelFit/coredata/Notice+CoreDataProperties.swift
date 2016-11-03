//
//  Notice+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension Notice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notice> {
        return NSFetchRequest<Notice>(entityName: "Notice");
    }

    @NSManaged public var callDelay: Int16
    @NSManaged public var callSwitch: Bool
    @NSManaged public var notifyItem: Int16
    @NSManaged public var notifySwitch: Bool

}
