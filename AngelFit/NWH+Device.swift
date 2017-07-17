//
//  NWH+Device.swift
//  AngelFit
//
//  Created by YiGan on 17/07/2017.
//  Copyright © 2017 aiju_huangjing1. All rights reserved.
//

import Foundation
public class NWHDevice{
    //MARK:- init ++++++++++++++++++++++++++++
    private static let __once = NWHDevice()
    public class func share() -> NWHDevice{
        return __once
    }
    
    //MARK:-新增设备
    /*
     * @param 
     */
    public func add(withParam param: [String: Any], closure: @escaping (_ resultCode: Int, _ message: String, _ data: Any?) -> ()){
        Session.session(withAction: Actions.deviceAdd, withMethod: Method.post, withParam: param, closure: closure)
    }
}
