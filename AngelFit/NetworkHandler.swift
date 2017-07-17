//
//  NetworkHandler.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation

//服务器地址
let host = "http://192.168.2.239:8080"

//请求类型
public struct Method{
    static let post = "POST"
    static let get = "GET"
}

//actions
public struct Actions{
    static let register             = "/user/add"               //注册
    static let logon                = "/user/logon"             //登录
    static let getInfo = "/getinfo"
    static let setInfo = "/setinfo"
    static let getPhoto = "/getphoto"
    static let setPhoto = "/setphoto"
}

//返回码
public struct ResultCode{
    static let failure  = 0
    static let success  = 1
    static let other    = 2
}

public final class NetworkHandler {

    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NetworkHandler()
    public class func share() -> NetworkHandler{
        return __once
    }
    
    //MARK:-注册
    public func register(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.register, withMethod: Method.post, withParam: param, closure: closure)
    }
    
    //MARK:-登陆
    public func login(withUserId userId: String, withPassword password: String, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.logon, withMethod: Method.get, withParam: ["userId": userId, "password": password], closure: closure)
    }
}
