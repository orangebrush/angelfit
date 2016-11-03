//
//  HandGesture+CoreDataProperties.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension HandGesture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HandGesture> {
        return NSFetchRequest<HandGesture>(entityName: "HandGesture");
    }

    @NSManaged public var displayTime: Int16
    @NSManaged public var isOpen: Bool

}
