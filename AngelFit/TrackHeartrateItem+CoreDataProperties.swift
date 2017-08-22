//
//  TrackHeartrateItem+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 08/03/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension TrackHeartrateItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackHeartrateItem> {
        return NSFetchRequest<TrackHeartrateItem>(entityName: "TrackHeartrateItem");
    }

    @NSManaged public var data: Int16
    @NSManaged public var offset: Int16
    @NSManaged public var id: Int16
    @NSManaged public var track: Track?

}
