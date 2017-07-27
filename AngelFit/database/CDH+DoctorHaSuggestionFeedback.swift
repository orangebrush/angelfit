//
//  CDH+DoctorHaSuggestionFeedback.swift
//  AngelFit
//
//  Created by ganyi on 2017/5/8.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataHandler{
    
    public func insertDoctorHaSuggestionFeedback(byId id: Int64, byObjectId objectId: Int64, byUserId userId: String? = nil) -> DoctorHaSuggestionFeedback?{
        
        guard let doctorHaSuggestion = selectDoctorHaSuggestion(byId: id, byObjectId: objectId, byUserId: userId) else{
            return nil
        }
        
        guard let feedback = NSEntityDescription.insertNewObject(forEntityName: "DoctorHaSuggestionFeedback", into: context) as? DoctorHaSuggestionFeedback else{
            return nil
        }
        
        doctorHaSuggestion.addToDoctorHaSuggestionFeedbackList(feedback)
        
        guard commit() else {
            return nil
        }
        return feedback
    }
    
    //MARK:- 根据userId与objectId查找反馈
    public func selectAllDoctorHaSuggestionFeedbacks(byObjectId objectId: Int64, byUserId userId: String? = nil) -> [DoctorHaSuggestionFeedback]{
        
        //判断userId
        guard let id = checkoutUserId(withOptionUserId: userId) else {
            return []
        }
        
        //查找
        let request: NSFetchRequest<DoctorHaSuggestionFeedback> = DoctorHaSuggestionFeedback.fetchRequest()
        let predicate = NSPredicate(format: "doctorHaSuggestion.userActivity.user.userId = \"\(id)\" AND doctorHaSuggestion.userActivity.objectId = \(objectId)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return []
        }
    }
    
    //MARK:- 删除最后一条feedback
    public func deleteDoctorHaSuggestionFeedback(byAdvisorId advisorId: Int64, byDoctorHaSuggestionId suggestionId: Int64, byObjectId objectId: Int64, byUserId userId: String? = nil){
        //判断userId
        guard let uid = checkoutUserId(withOptionUserId: userId) else {
            return
        }
        delete(DoctorHaSuggestionFeedback.self, byConditionFormat: "advisorId = \(advisorId), doctorHaSuggestion.id = \(suggestionId), doctorHaSuggestion.userActivity.user.userId = \"\(uid)\" AND doctorHaSuggestion.userActivity.objectId = \(objectId)")
    }
}
