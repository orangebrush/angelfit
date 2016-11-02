//
//  HeartRateItem+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 02/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData

extension HeartRateItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HeartRateItem> {
        return NSFetchRequest<HeartRateItem>(entityName: "HeartRateItem");
    }

    @NSManaged public var id: Int16
    @NSManaged public var offset: Int16
    @NSManaged public var data: Int16
    @NSManaged public var heartRateData: HeartRateData?

}
