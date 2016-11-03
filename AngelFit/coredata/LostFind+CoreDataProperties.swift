//
//  LostFind+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension LostFind {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LostFind> {
        return NSFetchRequest<LostFind>(entityName: "LostFind");
    }

    @NSManaged public var type: Bool

}
