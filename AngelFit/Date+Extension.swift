//
//  Date+Extension.swift
//  AngelFit
//
//  Created by ganyi on 2017/2/24.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
extension Date{
    public func GMT() -> Date{
        let zone = TimeZone.current
        let deltaTime: TimeInterval = TimeInterval(zone.secondsFromGMT(for: self))
        return self.addingTimeInterval(deltaTime)
    }
}
