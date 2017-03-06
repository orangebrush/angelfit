//
//  UserManager.swift
//  AngelFit
//
//  Created by ganyi on 2017/3/6.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
public class UserManager {
    
    public var userId: Int16 = 1
    
    //MARK: init--------------------------------------------
    private static var __once: () = {
        singleton.instance = UserManager()
    }()
    struct singleton{
        static var instance: UserManager! = nil
    }
    
    public class func share() -> UserManager{
        
        _ = UserManager.__once
        return singleton.instance
    }
}
