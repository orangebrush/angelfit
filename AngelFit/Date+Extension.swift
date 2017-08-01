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
    
    //转换为字符串
    func formatString(with dateFormat: String) -> String{
        let format = DateFormatter()
        format.dateFormat = dateFormat
        return format.string(from: self)
    }
    
    //获取星期字符串
    func weekdayString() -> String{
        let list = ["周日","周一","周二","周三","周四","周五","周六"]
        return list[weekday() - 1]
    }
    
    //获取星期 1234567
    func weekday() -> Int{
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }
    
    //偏移
    func offset(with offsetDay: Int, withTime timeFlag: Bool = false) -> Date {
        let resultDate = Date(timeInterval: TimeInterval(offsetDay) * 60 * 60 * 24, since: self)
        
        if timeFlag {
            return resultDate
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: resultDate)
        return calendar.date(from: components)!
    }
}
