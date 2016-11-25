//
//  GodFS.swift
//  AngelFit
//
//  Created by YiGan on 02/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreBluetooth
class GodFS {
    
    //MARK: init--------------------------------------------
    private static let __once = GodFS()
    class func share() -> GodFS {
        return __once
    }
    
    //file name
    private let fileName = "BindingPeripherals"
    //file bundle's path
    private var filePath: String!{
        return Bundle.main.path(forResource: "/Frameworks/AngelFit.framework/" + fileName, ofType: "plist")!
    }
    
    /*
     
     get UUIDStrings from plist file
 
     */
    var UUIDStringList: [String]{
        return readDictionary()
    }
    
    //MARK:- 获取文档路径
    private func documentPath() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        return path + "/" + fileName + ".plist"
    }
    
    //MARK:- 读取文档信息
    private func readDictionary() -> [String]{
        let fileManager = FileManager.default
        let fileExist = fileManager.fileExists(atPath: documentPath())
        var arr: NSArray!
        if fileExist {
            arr = NSArray(contentsOfFile: documentPath())
        }else{
            arr = NSArray(contentsOfFile: filePath)
        }
        
        var result = [String]()
        arr.forEach(){
            body in
            if let element: String = body as? String{
                result.append(element)
            }
        }
        return result
    }
    
    //MARK:- add new uuidstring @params: true-write successed : false-it's already existed or writed failed!
    func add(newUUIDString uuidString: String) -> Bool{
        
        var result = readDictionary()
        if result.contains(uuidString) {
            let oldIndex = result.index(of: uuidString)
            result.remove(at: oldIndex!)
            result.append(uuidString)
            return false
        }
        result.append(uuidString)
        
        let newResult = NSArray(array: result)
        if newResult.write(toFile: documentPath(), atomically: true){
            return true
        }
        return false
    }
    
    //MARK:- delete uuidstring
    func delete(UUIDString uuidString: String) -> Bool{
        
        var result = readDictionary()
        guard result.contains(uuidString) else {
            return false
        }
        
        guard let index = result.index(of: uuidString) else {
            return false
        }
        
        result.remove(at: index)
        
        let newResult = NSArray(array: result)
        if newResult.write(toFile: documentPath(), atomically: true){
            return true
        }
        return false
    }
    
    //MARK:- determine if device by UUID is banding
    func select(UUIDString uuidString: String) -> Bool{
        
        let result = readDictionary()
        if result.contains(uuidString) {
            return true
        }
        return false
    }
}
