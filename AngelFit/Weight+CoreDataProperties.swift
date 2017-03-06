//
//  Weight+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2017/3/6.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension Weight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weight> {
        return NSFetchRequest<Weight>(entityName: "Weight");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var value: Float
    @NSManaged public var user: User?

}
