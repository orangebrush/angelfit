//
//  SFClass.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/14.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import UIKit
public class CBridgingManager {
    
    let success: Int32 = 0
    let failure: Int32 = 14
    
    //存储所有定时器列表
    private var timerList = [Timer]()
    
    //获取未开始定时器列表
    private var offTimerList: [Timer]{
        get{
            return timerList.filter(){$0.task == nil}
        }
    }
    
    //自动获取唯一identify
    private var autoIdentify: Int32{
        get{
            return Int32(timerList.count)
        }
    }
    
    
    
    
    //MARK:- SHARE
    private static let cbridgingManager = CBridgingManager()
    public class func share() -> CBridgingManager {
        return cbridgingManager
    }
    
    init() {
        config()
        createBaseConfigure()
        createContents()
    }
    
    private func config(){
        
        //创建定时器
        swiftTimeCreateClosure = {
            _ -> Int32 in
            
            let timer = Timer(Int32(self.timerList.count))
            self.timerList.append(timer)
            return timer.identify
        }

        //启动定时器
        swiftTimerOnClosure = { identify, during_time_interval -> Int32 in
            
            //根据identify查找timer
            let arr = self.timerList.filter(){$0.identify == identify}
            guard let timer = arr.first else {
                return self.failure
            }
           
            //在during_time_interval秒后执行
            timer.task = delay(during_time_interval / 1000){
                timer.timerRestart()
            }
            
            return self.success
        }
        
        //MARK:-停止定时器
        swiftTimerOffClosure = { identify -> Int32 in
            
            //根据identify查找timer
            let arr = self.timerList.filter(){$0.identify == identify}
            guard let timer = arr.first else {
                return self.failure
            }
            
            //取消定时器
            cancel(timer.task)
            
            return self.success
        }
    }
    
    private func createContents(){
        initialization_c_function()
    }
}
