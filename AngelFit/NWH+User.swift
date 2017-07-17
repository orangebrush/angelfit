//
//  NH+User.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
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
    public func add(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.userAdd, withMethod: Method.post, withParam: param, closure: closure)
    }
    
    //MARK:-登陆
    /*
     * @param userId        require 用户id
     * @param password      option  旧密码
     */
    public func logon(withUserId userId: String, withPassword password: String, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.userLogon, withMethod: Method.post, withParam: ["userId": userId, "password": password], closure: closure)
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
    public func update(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.userUpdate, withMethod: Method.post, withParam: param, closure: closure)
    }
}
