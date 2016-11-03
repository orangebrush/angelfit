//
//  Alarm+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension Alarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Alarm> {
        return NSFetchRequest<Alarm>(entityName: "Alarm");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var duration: Int16
    @NSManaged public var id: Int16
    @NSManaged public var isRepeat: Bool
    @NSManaged public var status: Int16
    @NSManaged public var synchronize: Bool
    @NSManaged public var type: Int16

}
