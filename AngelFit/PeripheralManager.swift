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

    //MARK: init--------------------------------------------
    private static var __once: () = {
        singleton.instance = PeripheralManager()
    }()
    struct singleton{
        static var instance:PeripheralManager! = nil
    }
    
    class func share() -> PeripheralManager{
        
        _ = PeripheralManager.__once
        return singleton.instance
    }
    
    /*
     
     特征管理
     
     */
    //所有设备列表
    var peripheralMap = [String:CBPeripheral](){
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
    
    //所有设备特征列表
    var peripheralCharMap = [String:[CharacteristicType:CBCharacteristic]]()
    
    //切换
    public var UUID: String?
    
    //获取当前设备特征
    public var currentPeripheralChar:[CharacteristicType:CBCharacteristic]?{
        guard let uuid = UUID else {
            return nil
        }
        return peripheralCharMap[uuid]
    }
    
    //获取当前设备
    public var currentPeripheral: CBPeripheral?{
        guard let uuid = UUID else {
            return nil
        }
        
        return peripheralMap[uuid]
    }
    
    /*
     
     UUID管理
     
     */
    //获取绑定设备列表
    public func selectUUIDStringList() -> [String]{
        return GodFS.share.UUIDStringList
    }
    
    //添加绑定设备
    public func add(newUUIDString uuidString: String) -> Bool{
        return GodFS.share.add(newUUIDString: uuidString)
    }
    
    //删除绑定设备
    public func delete(UUIDString uuidString: String) -> Bool{
        return GodFS.share.delete(UUIDString: uuidString)
    }
    
    //判断是否绑定
    public func select(UUIDString uuidString: String) -> Bool{
        return GodFS.share.select(UUIDString: uuidString)
    }
}
