//
//  HandGesture+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 02/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension HandGesture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HandGesture> {
        return NSFetchRequest<HandGesture>(entityName: "HandGesture");
    }

    @NSManaged public var isOpen: Bool
    @NSManaged public var displayTime: Int16

}
