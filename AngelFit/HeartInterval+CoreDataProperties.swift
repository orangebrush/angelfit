//
//  HeartInterval+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 21/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension HeartInterval {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HeartInterval> {
        return NSFetchRequest<HeartInterval>(entityName: "HeartInterval");
    }

    @NSManaged public var limit: Int16
    @NSManaged public var burnFat: Int16
    @NSManaged public var aerobic: Int16
    @NSManaged public var heartRateMode: Int16

}
