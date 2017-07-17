//
//  Session.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
class Session {
    class func session(withAction action: String, withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message:String, _ data: Any?) -> ()) {
        
        do{
            let body = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let urlStr = host + action
            guard let url = URL(string: urlStr) else{
                return
            }
            
            var request =  URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {
                binaryData, response, error in
                
                /*
                 通过response["result"]判断后台返回数据是否合法
                 resultCode == 1 ------成功
                 resultCode == 0 ------失败
                 resultCode == 2 ------待定
                 */
                guard error == nil else{
                    closure(0, "error", nil)
                    debugPrint("<Session> 请求错误: \(String(describing: error))")
                    return
                }
                
                do{
                    guard let result = try JSONSerialization.jsonObject(with: binaryData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else{
                        closure(0, "获取数据错误", nil)
                        return
                    }
                    
                    debugPrint("<Session> result: \(result)")
                    
                    guard let resultCode = result["resultCode"] as? Int, let message = result["message"] as? String else {
                        closure(0, "解析数据错误", nil)
                        return
                    }
                    
                    if let data = result["data"]{
                        closure(resultCode, message, data)
                    }else{
                        closure(resultCode, message, nil)
                    }
                }catch let responseError{
                    debugPrint("<Session> 数据处理错误: \(responseError)")
                }
            })
            
            task.resume()
        }catch let error{
            debugPrint("<Session> 解析二进制数据错误: \(error)")
        }
    }
    
    //MARK:-上传图片
    class func upload(_ image: UIImage, userid: Int64, closure: @escaping (_ resultCode: Int, _ message:String, _ data: Any?) -> ()){
        
        //1.数据体
        guard let data = UIImagePNGRepresentation(image) else {
            debugPrint("<Session> 获取图片数据错误")
            return
        }
        
        //2.Request
        let urlStr = host + Actions.setPhoto + "?userid=\(userid)"
        guard let url = URL(string: urlStr) else{
            debugPrint("<Session> 生成url错误")
            return
        }
        
        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.addValue("image/png", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.uploadTask(with: request as URLRequest, from: data, completionHandler: {
            binaryData,response,error in
            
            
            guard error == nil else{
                closure(0, "上传失败", nil)
                return
            }
            
            do{
                guard let result = try JSONSerialization.jsonObject(with: binaryData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] else{
                    closure(0, "数据错误", nil)
                    return
                }
                
                debugPrint("<Session> result: \(result)")
                
                guard let resultCode = result["resultCode"] as? Int, let message = result["message"] as? String else {
                    closure(0, "解析数据错误", nil)
                    return
                }
                
                if let data = result["data"]{
                    closure(resultCode, message, data)
                }else{
                    closure(resultCode, message, nil)
                }
            }catch let responseError{
                debugPrint("<Session> 数据处理错误: \(responseError)")
            }
        })
        task.resume()
    }
}
