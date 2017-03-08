//
//  TrackItem+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 08/03/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension TrackItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackItem> {
        return NSFetchRequest<TrackItem>(entityName: "TrackItem");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var interval: Double
    @NSManaged public var subDistance: Double
    @NSManaged public var longtitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var track: Track?

}
