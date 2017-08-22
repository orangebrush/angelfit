//
//  TimeModel.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/14.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import UIKit

class TimeModel: NSObject {
      fileprivate  var tagNew = 0
      fileprivate  var stopCount = 0
    public func timerRepeat(){
        if (self.stopCount>0) {
            self.stopCount=0;
            if (self.stopCount<=0) {
                SFClass.shareOCClass.startArray.remove(at: SFClass.shareOCClass.startArray.index(of: self)!)
                //ProtocolLibTimerHandler((int)self.tagNew);
            }
        }

    }
}
