//
//  NH+User.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
//用户注册参数
public struct NWHUserAddParam{
    public var userId: String
    public var password: String
    public var email: String
    public var weixin: String
    public var mobile: String
    public var showName: String
}
//用户登陆参数
public struct NWHUserLogonParam{
    public var userId: String
    public var password: String
}
//用户更新参数
public struct NWHUserUpdateParam{
    public var userId: String
    public var password: String
    public var email: String
    public var weixin: String
    public var mobile: String
    public var showName: String
    public var newPassword: String
}
public class NWHUser {
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NWHUser()
    public class func share() -> NWHUser{
        return __once
    }
    
    //MARK:-注册
    /*
     * @param userId        require 用户id
     * @param password      require 旧密码
     * @param email         option  邮箱地址
     * @param weixin        option  微信
     * @param mobile        option  手机号
     * @param showName      option  昵称
     */
    public func add(withParam param: NWHUserAddParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        let dict = [
            "userId": param.userId,
            "password": param.password,
            "email": param.email,
            "weixin": param.weixin,
            "mobile": param.mobile,
            "showName": param.showName
        ]
        Session.session(withAction: Actions.userAdd, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-登陆
    /*
     * @param userId        require 用户id
     * @param password      option  旧密码
     */
    public func logon(withParam param: NWHUserLogonParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        let dict = [
            "userId": param.userId,
            "password": param.password
        ]
        Session.session(withAction: Actions.userLogon, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-更新
    /*
     * @param userId        require 用户id
     * @param password      require 旧密码
     * @param email         option 邮箱地址
     * @param weixin        option 微信
     * @param mobile        option 手机号
     * @param showName      option 昵称
     * @param newPassword   option 新密码
     */
    public func update(withParam param: NWHUserUpdateParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        let dict = [
            "userId": param.userId,
            "password": param.password,
            "email": param.email,
            "weixin": param.weixin,
            "mobile": param.mobile,
            "showName": param.showName,
            "newPassword": param.newPassword
        ]
        Session.session(withAction: Actions.userUpdate, withMethod: Method.post, withParam: dict, closure: closure)
    }
}
