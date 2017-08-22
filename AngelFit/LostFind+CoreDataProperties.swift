//
//  LostFind+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 21/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension LostFind {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LostFind> {
        return NSFetchRequest<LostFind>(entityName: "LostFind");
    }

    @NSManaged public var type: Bool

}
