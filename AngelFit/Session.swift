//
//  Session.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
class Session {
    class func session(withAction action: String, withMethod method: String, withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message:String, _ data: Any?) -> ()) {
        
        //回调函数
        let completionHandler = {(binaryData: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else{
                closure(ResultCode.failure, "error", nil)
                debugPrint("<Session> 请求错误: \(String(describing: error))")
                return
            }
            
            do{
                guard let result = try JSONSerialization.jsonObject(with: binaryData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else{
                    closure(ResultCode.failure, "获取数据错误", nil)
                    return
                }
                
                debugPrint("<Session> result: \(result)")
                
                guard let resultCode = result["resultCode"] as? Int, let message = result["message"] as? String else {
                    closure(ResultCode.failure, "解析数据错误", nil)
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
        }
        
        //post or get
        let isPost = method == Method.post
        do{
            
            var urlStr = host + action
            if !isPost {
                for (offset: index, element: (key: key, value: value)) in param.enumerated(){
                    if index == 0{
                        urlStr += "?"
                    }else{
                        urlStr += "&"
                    }
                    let v = value as! String
                    urlStr.append(key + "=" + v)
                }
            }
            
            //生成url
            guard let url = URL(string: urlStr) else{
                return
            }
            
            var request: URLRequest!
            if isPost {
                let body = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
                request =  URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                request.httpMethod = method
                
                //与用户相关请求采用form格式
                if action == Actions.userLogon || action == Actions.userAdd || action == Actions.userUpdate {
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    var form = ""
                    for (offset: index, element: (key: key, value: value)) in param.enumerated() {
                        if index != 0 {
                            form += "&"
                        }
                        let v = value as! String
                        form.append(key + "=" + v)
                    }
                    request.httpBody = form.data(using: .utf8)
                }else {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                }
            }
            
            let session = URLSession.shared
            var task: URLSessionDataTask
            if isPost {
                task = session.dataTask(with: request, completionHandler: completionHandler)
            }else{
                task = session.dataTask(with: url, completionHandler: completionHandler)
            }
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
