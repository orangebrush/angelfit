//
//  CoreDataHandler.swift
//  AngelFit
//
//  Created by ganyi on 2016/11/2.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHandler {
    
    class func getUser(){
        do{
            let description = NSEntityDescription.entity(forEntityName: "User", in: context)
            let user = User(entity: description!, insertInto: context)
            user.gender = "男"
            try context.save()
        }catch let error{
            
        }
    }
}
