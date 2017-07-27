//
//  CDH+DoctorHaSuggestion.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/8.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    public func insertDoctorHaSuggestion(byObjectId objectId: Int64, byUserId userId: String? = nil) -> DoctorHaSuggestion?{
        
        guard let userActivity = selectUserActivity(withObjectId: objectId, byUserId: userId) else{
            return nil
        }
        
        var id: Int64 = 0
        if let lastDoctorHaSuggestion = selectAllDoctorHaSuggestions(byObjectId: objectId, byUserId: userId).last{
            id = lastDoctorHaSuggestion.id + 1         //增1
        }
        
        guard let doctorHaSuggestion = NSEntityDescription.insertNewObject(forEntityName: "DoctorHaSuggestion", into: context) as? DoctorHaSuggestion else{
            return nil
        }
        
        doctorHaSuggestion.id = id
        
        userActivity.addToDoctorHaSuggestionList(doctorHaSuggestion)
        
        guard commit() else {
            return nil
        }
        return doctorHaSuggestion
    }
    
    public func selectDoctorHaSuggestion(byId id: Int64, byObjectId objectId: Int64, byUserId userId: String? = nil) -> DoctorHaSuggestion?{
        
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return nil
        }
        
        //查找
        let request: NSFetchRequest<DoctorHaSuggestion> = DoctorHaSuggestion.fetchRequest()
        let predicate = NSPredicate(format: "id = \(id) AND userActivity.user.userId = \"\(uid)\" AND userActivity.objectId = \(objectId)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            if let last = resultList.last {
                return last
            }
        }catch let error{
            fatalError("<Core Data> fetch error: \(error)")
        }
        return nil
    }
    
    public func selectAllDoctorHaSuggestions(byObjectId objectId: Int64, byUserId userId: String? = nil) -> [DoctorHaSuggestion]{
        
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //查找
        let request: NSFetchRequest<DoctorHaSuggestion> = DoctorHaSuggestion.fetchRequest()
        let predicate = NSPredicate(format: "userActivity.user.userId = \"\(id)\" AND userActivity.objectId = \(objectId)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch error: \(error)")
        }
        return []
    }
    
    public func deleteDoctorHaSuggestion(byId id: Int64, byObjectId objectId: Int64, byUserId userId: String? = nil){
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return
        }
        delete(UserActivityComment.self, byConditionFormat: "id = \(id), userActivity.user.userId = \"\(uid)\" AND userActivity.objectId = \(objectId)")
    }
}
