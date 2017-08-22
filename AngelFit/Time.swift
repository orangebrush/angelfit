//
//  Time.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/1.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
typealias TimeTask = (_ cancel: Bool)->()
func delay(_ time: TimeInterval, task: @escaping ()->()) -> TimeTask?{
    func dispathLater(_ block: @escaping ()->()){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
    }
    
    var closure: (()->())? = task
    var result: TimeTask?
    
    let delayedClosure: TimeTask = {
        cancel in
        if let internalClosure = closure {
            if !cancel {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispathLater {
        if let delayedClosure = result{
            delayedClosure(false)
        }
    }
    
    return result
}

func cancel(_ task: TimeTask?){
    task?(true)
}
