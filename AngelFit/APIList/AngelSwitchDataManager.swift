//
//  AngelSwitchDataManager.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2017/2/10.
//  Copyright © 2017年 aiju_huangjing1. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth
class AngelSwitchDataManager: NSObject {
    private static var __once: AngelSwitchDataManager? {
        return AngelSwitchDataManager()
    }
    public class func share() -> AngelSwitchDataManager?{
        return __once
    }
    private let angelManager = AngelManager.share()
    private var macAddress : String?
    
    override init(){
    super.init()
        //初始化获取macAddress
        angelManager?.getMacAddressFromBand(){
            errorCode, data in
            if errorCode == ErrorCode.success{
                self.macAddress = data
            }
        }
    }
    //交换数据
    
    
}
