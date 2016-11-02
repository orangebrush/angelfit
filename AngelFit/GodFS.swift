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
    
    private static let __once = GodFS()
    
    //MARK: init--------------------------------------------
    class var share: GodFS {
        return __once
    }
    
    private let fileName = "BindingPeripherals"                             //文件名
    private var filePath: String!{
        return Bundle.main.path(forResource: fileName, ofType: "plist")!
    }                                                                       //文件路径
    var bindingList: [String]{
        return readDictionary()
    }                                                                       //获取绑定的手环_uuidString列表
    
    //MARK:- 获取文档路径
    private func documentPath() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        return path + "/" + fileName + ".plist"
    }
    
    //MARK:- 读取路径信息
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
            return false
        }
        result.append(uuidString)
        
        let newResult = NSArray(array: result)
        if newResult.write(toFile: documentPath(), atomically: true){
            return true
        }
        return false
    }
}
