//
//  Track+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 08/03/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track");
    }

    @NSManaged public var aerobicMinutes: Int16
    @NSManaged public var avgrageHeartrate: Int16
    @NSManaged public var burnFatMinutes: Int16
    @NSManaged public var calories: Int16
    @NSManaged public var date: NSDate?
    @NSManaged public var distance: Double
    @NSManaged public var durations: Int16
    @NSManaged public var limitMinutes: Int16
    @NSManaged public var maxHeartrate: Int16
    @NSManaged public var serial: Int16
    @NSManaged public var step: Int16
    @NSManaged public var type: Int16
    @NSManaged public var device: Device?
    @NSManaged public var trackItems: NSSet?
    @NSManaged public var trackHeartrateItems: NSSet?

}

// MARK: Generated accessors for trackItems
extension Track {

    @objc(addTrackItemsObject:)
    @NSManaged public func addToTrackItems(_ value: TrackItem)

    @objc(removeTrackItemsObject:)
    @NSManaged public func removeFromTrackItems(_ value: TrackItem)

    @objc(addTrackItems:)
    @NSManaged public func addToTrackItems(_ values: NSSet)

    @objc(removeTrackItems:)
    @NSManaged public func removeFromTrackItems(_ values: NSSet)

}

// MARK: Generated accessors for trackHeartrateItems
extension Track {

    @objc(addTrackHeartrateItemsObject:)
    @NSManaged public func addToTrackHeartrateItems(_ value: TrackHeartrateItem)

    @objc(removeTrackHeartrateItemsObject:)
    @NSManaged public func removeFromTrackHeartrateItems(_ value: TrackHeartrateItem)

    @objc(addTrackHeartrateItems:)
    @NSManaged public func addToTrackHeartrateItems(_ values: NSSet)

    @objc(removeTrackHeartrateItems:)
    @NSManaged public func removeFromTrackHeartrateItems(_ values: NSSet)

}
