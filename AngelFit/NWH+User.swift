//
//  NH+User.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
//用户验证码参数
public class NWHUserVerificationCodeParam: NSObject {
    public var email: String? = nil
}

//用户注册参数
public class NWHUserRegisterParam: NSObject {
    public var userId: String? = nil
    public var password: String? = nil
    public var confirm: String? = nil
}

//用户修改密码参数
public class NWHUserChangePasswordParam: NSObject {
    public var userId: String? = nil
    public var newPassword: String? = nil
}

//用户验证码合法参数
public class NWHUserConfirmVerificationCodeParam: NSObject {
    public var userId: String? = nil
    public var code: String? = nil
}

//用户登陆参数
public class NWHUserLogonParam: NSObject {
    public var userId: String?
    public var password: String?
}

//用户更新参数
public class NWHUserUpdateParam: NSObject {
    public var userId: String?
    public var password: String?
    public var email: String?
    public var weixin: String?
    public var mobile: String?
    public var showName: String?
    public var heightCM: Int = 170
    public var weightG: Int = 65
    public var genderBoy: Bool = true
    public var birthday: Date?
}

//用户上传头像
public class NWHUserUploadParam: NSObject {
    public var userId: String?
    public var image: UIImage?
}

//MARK:-正则表达式
struct Regex {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input, options: [], range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        }
        return false
    }
}

public class NWHUser: NSObject {
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NWHUser()
    public class func share() -> NWHUser{
        return __once
    }
    
    //MARK:-验证用户id合法
    func isUserIdLegel(withUserId userId: String?) -> Bool {
        guard let uid = userId else {
            return false
        }
        
        let mailPattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,10})$"
        let matcher = Regex(mailPattern)
        let maybeMailAddress = uid
        guard matcher.match(input: maybeMailAddress) else {
            return false
        }
        return true
    }
    
    //MARK:-验证密码合法
    func isPasswordLegel(withPassword password: String?) -> Bool{
        //判断密码是否为空
        guard let pw = password else {
            return false
        }
        
        //去除空格与换行
        let length = pw.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count
        
        guard length > 5 else {
            return false
        }
        return true
    }
    
    //MARK:-查询邮箱是否已注册
    public func checkExist(withUserId userId: String,  closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        guard isUserIdLegel(withUserId: userId) else {
            closure(ResultCode.failure, "userid is not legel", nil)
            return
        }
        let dict = [
            "userId": userId
        ]
        Session.session(withAction: Actions.checkExist, withMethod: Method.get, withParam: dict, closure: closure)
    }
    
    //MARK:-获取验证码(用户注册与修改密码)
    /*
     * @param email         require 邮箱
     */
    public func getVerificationCode(withParam param: NWHUserVerificationCodeParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        var dict = [String: Any]()
        guard let email = param.email else {
            closure(ResultCode.emailAndVerifiEmpty, "email is empty", nil)
            return
        }
        
        guard isUserIdLegel(withUserId: email) else {
            closure(ResultCode.failure, "param is not legel", nil)
            return
        }
        
        dict["email"] = email
        
        Session.session(withAction: Actions.getVerificationCode, withMethod: Method.get, withParam: dict, closure: closure)
    }
    
    //MARK:-注册
    /*
     * @param userId        require 用户id(邮箱,服务器端会全部转为小写字符)
     * @param password      require 密码
     * @param confirm       require 验证码
     */
    public func register(withParam param: NWHUserRegisterParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [String: Any]()
        guard let userId = param.userId, let password = param.password, let confirm = param.confirm else {
            closure(ResultCode.userIdAndPasswordEmpty, "param is empty", nil)
            return
        }
        
        guard isUserIdLegel(withUserId: userId) && isPasswordLegel(withPassword: password) else {
            closure(ResultCode.passwordLengthError, "param is not legel", nil)
            return
        }
        
        dict["userId"] = userId
        dict["password"] = password
        dict["code"] = confirm
        
        Session.session(withAction: Actions.userRegister, withMethod: Method.post, withParam: dict, closure: {
            resultCode, message, data in
            if resultCode == ResultCode.success {
                //存储用户
                //let coredataHandler = CoreDataHandler.share()
                //_ = coredataHandler.insertUser(withUserId: userId)
            }
            closure(resultCode, message, data)
        })
    }
    
    //MARK:-核对用户验证码
    /*
     * @param userId        require 用户id
     * @param code          require 验证码
     */
    public func confirmVerificationCode(withParam param: NWHUserConfirmVerificationCodeParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        var dict = [String: Any]()
        guard let userId = param.userId, let code = param.code else {
            closure(ResultCode.failure, "param is empty", nil)
            return
        }
        
        guard isUserIdLegel(withUserId: userId) else {
            closure(ResultCode.failure, "userId is not legel", nil)
            return
        }
        
        dict["userId"] = userId
        dict["code"] = code
        
        Session.session(withAction: Actions.confirmVerificationCode, withMethod: Method.get, withParam: dict, closure: closure)
    }
    
    //MARK:-修改密码
    /*
     * @param userId        require 用户id
     * @param newPassword   require 新密码
     */
    public func changePassword(withParam param: NWHUserChangePasswordParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()) {
        var dict = [String: Any]()
        guard let userId = param.userId, let newPassword = param.newPassword else{
            closure(ResultCode.failure, "param is empty", nil)
            return
        }
        
        guard isUserIdLegel(withUserId: userId) && isPasswordLegel(withPassword: newPassword) else {
            closure(ResultCode.failure, "param is not legel", nil)
            return
        }
        
        dict["userId"] = userId
        dict["newPassword"] = newPassword
        
        Session.session(withAction: Actions.userChangePassword, withMethod: Method.post, withParam: dict, closure: closure)
    }
 
    //MARK:-登陆
    /*
     * @param userId        require 用户id
     * @param password      require 旧密码
     */
    public func logon(withParam param: NWHUserLogonParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [String: Any]()
        guard let userId = param.userId, let password = param.password else {
            closure(ResultCode.failure, "param is empty", nil)
            return
        }
        
        guard isUserIdLegel(withUserId: userId) && isPasswordLegel(withPassword: password) else {
            closure(ResultCode.userIdAndPasswordEmpty, "param is not legel", nil)
            return
        }
        
        dict["userId"] = userId
        dict["password"] = password
        
        Session.session(withAction: Actions.userLogon, withMethod: Method.post, withParam: dict, closure: closure)
        Session.session(withAction: Actions.userLogon, withMethod: Method.post, withParam: dict, closure: {
            resultCode, message, data in
            if resultCode == ResultCode.success {
                //let coredataHandler = CoreDataHandler.share()
                //_ = coredataHandler.insertUser(withUserId: userId)
            }
            closure(resultCode, message, data)
        })
    }
    
    //MARK:-更新用户信息
    /*
     * @param userId        require 用户id
     * @param password      require 密码
     * @param email         option  邮箱地址
     * @param weixin        option  微信
     * @param mobile        option  手机号
     * @param showName      option  昵称
     * @param height        option  升高 cm 
     * @param weight        option  体重 g
     * @param gender        option  性别
     * @param birthday      option  生日
     */
    public func update(withParam param: NWHUserUpdateParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        var dict = [String: Any]()
        guard let userId = param.userId, let password = param.password else {
            closure(ResultCode.failure, "userId or password is empty", nil)
            return
        }
        
        guard isUserIdLegel(withUserId: userId) && isPasswordLegel(withPassword: password) else {
            closure(ResultCode.failure, "param is not legel", nil)
            return
        }
        
        dict["userId"] = userId
        dict["password"] = password
        
        if let email = param.email {
            dict["email"] = email
        }
        if let weixin = param.weixin {
            dict["weixin"] = weixin
        }
        if let mobile = param.mobile {
            dict["mobile"] = mobile
        }
        if let showName = param.showName {
            dict["showName"] = showName
        }

        dict["height"] = "\(param.heightCM)"
    
        dict["weight"] = "\(param.weightG)"
        
        dict["gender"] = param.genderBoy ? "M" : "F"

        if let birthday = param.birthday {
            dict["birthday"] = birthday.formatString(with: "yyyy-MM-dd")
        }
        
        Session.session(withAction: Actions.userModify, withMethod: Method.post, withParam: dict, closure: closure)
    }
    
    //MARK:-上传头像文件
    /*
     * @param userId        require 用户id
     * @param file          require 文件
     */
    public func uploadPhoto(withParam param: NWHUserUploadParam, closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        guard let userId = param.userId, let image = param.image else {
            closure(ResultCode.userIdEmpty, "userId or image is empty", nil)
            return
        }
        Session.upload(image, userid: userId, closure: closure)
    }
}
