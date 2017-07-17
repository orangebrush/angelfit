//
//  NetworkHandler.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation

//服务器地址
let host = "https://192.168.2.239:8080"

//actions
struct Actions{
    static let register             = "/register"               //注册
    static let login                = "/login"                  //登录
    static let getInfo = "/getinfo"
    static let setInfo = "/setinfo"
    static let getPhoto = "/getphoto"
    static let setPhoto = "/setphoto"
}

public final class NetworkHandler {

    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NetworkHandler()
    public class func share() -> NetworkHandler{
        return __once
    }
    
    //MARK:-注册
    
    //MARK:-登陆
    public func login(withUserId userId: String, withPassword password: String, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.login, withParam: ["userId": userId, "password": password], closure: closure)
    }
}
