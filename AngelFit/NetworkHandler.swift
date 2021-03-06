//
//  NetworkHandler.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
//服务器地址
let host = true ? "http://119.23.239.138:80" : "http://192.168.2.239:80"

//请求类型
public struct Method{
    static let post = "POST"
    static let get = "GET"
}

//actions
enum Actions{
    static let checkExist           = "/user/exists"            //查询是否已注册
    static let getVerificationCode  = "/user/getCode"           //获取验证码
    static let confirmVerificationCode = "/user/confirm"        //验证验证码合法(仅修改密码使用)
    
    static let userRegister         = "/user/register"          //新增用户
    static let userChangePassword   = "/user/changePassword"    //修改密码
    static let userLogon            = "/user/logon"             //用户登陆
    static let userModify           = "/user/modify"            //更新用户信息
    
    static let uploadPhoto          = "/upload"                 //更新头像
    
    static let deviceAdd            = "/device/add"             //新增设备
    static let deviceUpdate         = "/device/update"          //更新设备
    static let deviceStatus         = "/deviceStatus/add"       //记录设备状态
    static let deviceAddFunctable   = "/function/add"           //添加功能列表
    static let deviceUpdateFunctable = "/function/update"       //更新功能列表
    static let deviceUpdateMessage  = "/deviceMessage/update"   //更新社交列表
    static let deviceErrorLog       = "/deviceErrorLog/add"     //记录设备错误日志
    
    static let everydayHeartratesAdd = "/heartrate/recordHeartRates"    //post上传每日心率
    static let everydayHeartratesPull = "/heartrate/recoverHeartRates"  //get下拉每日心率
    static let everydayStepAdd = "/sport/recordSteps"                   //post上传每日步数
    static let everydayStepPull = "/sport/recoverSteps"                 //get下拉每日步数
    static let everydaySleepAdd = "/sleep/recordSleeps"                 //post上传每日睡眠
    static let everydaySleepPull = "/sleep/recoverSleeps"               //get下拉每日睡眠
    static let everydayTrainingAdd = "/train/recordTrains"              //post上传每日训练
    static let everydayTrainingPull = "/train/recoverTrains"            //get下拉每日训练
    
    static let getLastAcynTime = "/user/getLastRecordDateTime"  //get查询用户与设备最后更新时间
}

//返回码
public struct ResultCode{
    public static let failure                   = 0
    public static let success                   = 1
    public static let other                     = 2
    
    public static let accountExist              = 10000         //用户已经存在
    public static let userIdEmpty               = 10001         //用户标识为空
    public static let accountNotExist           = 10002         //帐户不存在
    public static let logonFailure              = 10003         //用户登录失败
    public static let userIdAndDeviceIdEmpty    = 10004         //必须同时需要用户ID和设备ID
    public static let emailAndVerifiEmpty       = 10005         //必须邮箱和验证码
    public static let verifiInvalid             = 10006         //校验码不存在或已过期
    public static let verifiError               = 10007         //校验码错误
    public static let userIdNaN                 = 10008         //用户ID对象不为空，但值为空。
    public static let passwordLengthError       = 10009         //密码长度必须大于等于5
    public static let userIdAndPasswordEmpty    = 10010         //密码和用户帐号不能为空。
    public static let deviceIdEmpty             = 20000         //必须要有设备标识
    public static let deviceExist               = 20001         //设备已经存在
    public static let errorMessageEmpty         = 20002         //设备的错误信息不能为空
    public static let functableNotFound         = 20003         //没有找到设备的硬件能力记录
    public static let fileEmpty                 = 20004         //上传的文件为空
    public static let fileNotImage              = 20005         //必须是图片文件
}

public final class NetworkHandler: NSObject {
    
    //用户
    public lazy var user: NWHUser = {
        return NWHUser.share()
    }()
    
    //设备
    public lazy var device: NWHDevice = {
        return NWHDevice.share()
    }()
    
    //每日数据
    public lazy var everyday: NWHEverydayData = {
        return NWHEverydayData.share()
    }()
    
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NetworkHandler()
    public class func share() -> NetworkHandler{
        return __once
    }
    
    //临时记录步数
    public func updateSteps(withUserId userId: String, steps: Int, date: Date, closure: @escaping (_ resultCode: Int, _ message:String, _ data: Any?) -> ()){
        do{
            let dateStr = date.formatString(with: "yyyy-MM-dd")
            let body: [String : Any] = [
                "userId": userId,
                "steps": steps,
                "date": dateStr
            ]
            let requestData=try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let url = URL(string: "http://123.207.126.246:9090/addsteps")
            var request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: {
                
                data, response, error in
                
                //切换到主线程
                DispatchQueue.main.async{
                    guard error == nil else{
                        closure(ResultCode.failure, "<记步>连接错误", nil)
                        return
                    }
                    
                    do{
                        guard let result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject] else{
                            closure(ResultCode.failure, "<记步>获取数据错误", nil)
                            return
                        }
                        
                        /*
                         通过response["result"]判断后台返回数据是否合法
                         result == 1 ------true
                         result == 0 ------false
                         */
                        print("返回:\(result)")
                        closure(ResultCode.success, "<记步>上传完成", result)
                    }catch let responseError{
                        print("response数据处理错误: \(responseError)")
                    }
                }
            })
            
            task.resume()
        }catch let error{
            print("request数据处理错误: \(error)")
        }
    }
    
    //临时拉取步数
    public func pullSteps(with target: Int, date: Date, closure: @escaping (_ resultCode: Int, _ message:String, _ data: Any?) -> ()){
        do{
            let dateStr = date.formatString(with: "yyyy-MM-dd")
            let body: [String : Any] = [
                "target": target,
                "date": dateStr
            ]
            let requestData=try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let url = URL(string: "http://123.207.126.246:9090/selectsteps")
            var request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: {
                
                data, response, error in
                
                //切换到主线程
                DispatchQueue.main.async{
                    guard error == nil else{
                        closure(ResultCode.failure, "<记步>连接错误", nil)
                        return
                    }
                    
                    do{
                        guard let result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject] else{
                            closure(ResultCode.failure, "<记步>获取数据错误", nil)
                            return
                        }
                        
                        /*
                         通过response["result"]判断后台返回数据是否合法
                         result == 1 ------true
                         result == 0 ------false
                         */
                        print("返回:\(result)")
                        closure(ResultCode.success, "<记步>拉取完成", result)
                    }catch let responseError{
                        print("response数据处理错误: \(responseError)")
                    }
                }
            })
            
            task.resume()
        }catch let error{
            print("request数据处理错误: \(error)")
        }
    }
}
