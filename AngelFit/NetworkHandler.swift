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
enum Actions{
    static let userAdd              = "/user/add"               //新增用户
    static let userLogon            = "/user/logon"             //用户登陆
    static let userUpdate           = "/user/update"            //更新用户
    
    static let deviceAdd            = "/device/add"             //新增设备
    static let deviceUpdate         = "/device/update"          //更新设备
    
    static let everydayHeartratesAdd = "/heartrate/recordHeartRates"    //post上传每日心率
    static let everydayHeartratesPull = "/heartrate/recordHeartRates"   //get下拉每日心率
    static let everydayStepAdd = "/sport/recordSteps"                   //post上传每日步数
    static let everydayStepPull = "/sport/recoverSteps"                 //get下拉每日步数
    static let everydaySleepAdd = "/sleep/recordSleeps"                 //post上传每日睡眠
    static let everydaySleepPull = "/sleep/recoverSleeps"               //get下拉每日睡眠
    static let everydayTrainingAdd = "/train/recordTrains"              //post上传每日训练
    static let everydayTrainingPull = "/train/recoverTrains"            //get下拉每日训练
    
    static let lastAcynTime = "/"    //post查询用户与设备最后更新时间
    
    static let setPhote = "/setPhoto"                  //更新头像
}

//返回码
public struct ResultCode{
    static let failure  = 0
    static let success  = 1
    static let other    = 2
}

public final class NetworkHandler {
    
    //用户
    public lazy var user: NWHUser = {
        return NWHUser.share()
    }()
    
    //设备
    public lazy var device: NWHDevice = {
        return NWHDevice.share()
    }()
    
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NetworkHandler()
    public class func share() -> NetworkHandler{
        return __once
    }
}
