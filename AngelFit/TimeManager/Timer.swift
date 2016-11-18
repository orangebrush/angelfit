//
//  TimerModel.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/15.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation


public class Timer {
    
    public var identify: Int32!
    
    var task: TimeTask?
    
    init(_ initIdentify: Int32) {
        identify = initIdentify
    }
    
    init() {
        
    }
    
    public func timerRestart(){
         ProtocolLibTimerHandler(UInt32(self.identify));
    }
}
