//
//  SportItem+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData

extension SportItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SportItem> {
        return NSFetchRequest<SportItem>(entityName: "SportItem");
    }

    @NSManaged public var activeTime: Int16
    @NSManaged public var calories: Int16
    @NSManaged public var distance: Int16
    @NSManaged public var id: Int16
    @NSManaged public var mode: Int16
    @NSManaged public var sportCount: Int16
    @NSManaged public var sportData: SportData?

}
