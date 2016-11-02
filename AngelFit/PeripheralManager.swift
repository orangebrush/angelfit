//
//  PeripheralInstance.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/1.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import UIKit
import CoreBluetooth
public class PeripheralManager: NSObject {

    private static var __once: () = {
        singleton.instance = PeripheralManager()
    }()
    
    public var peripheralMap = [String:CBPeripheral](){
        didSet{
            peripheralCharMap.forEach(){
                UUID, peripheral in

                guard peripheralCharMap[UUID] != nil else{
                    let charMap = [CharacteristicType: CBCharacteristic]()
                    peripheralCharMap[UUID] = charMap
                    return
                }
            }
        }
    }//key: uuid, value: peripheral
    
    public var UUID: String?
    
    public var currentPeripheralChar:[CharacteristicType:CBCharacteristic]?{
        guard let uuid = UUID else {
            return nil
        }
        return peripheralCharMap[uuid]
    }//保存当前设备特征
    
    public var peripheralCharMap = [String:[CharacteristicType:CBCharacteristic]]()    //所有设备特征
    
    //MARK: init--------------------------------------------
    struct singleton{
        static var onceToken:Int = 0
        static var instance:PeripheralManager! = nil
    }
    
    class func share() -> PeripheralManager{
        
        _ = PeripheralManager.__once
        return singleton.instance
    }
    
    
}
