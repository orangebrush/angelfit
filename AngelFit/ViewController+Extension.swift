//
//  ViewController+Extension.swift
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/1.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

import UIKit
import CoreBluetooth
extension UIViewController : CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let err = error else {
            peripheral.services?.forEach(){
                service in
                peripheral .discoverCharacteristics(nil, for: service)
            }
            return
        }

        print("发现服务error:\n error:\(err)\n")
        DispatchQueue.main.async {
    
            let name = peripheral.name ?? ""
            
            let alertController = UIAlertController(title: "Error", message: "\(name)\n连接服务失败", preferredStyle: .alert)
            let action = UIAlertAction(title: "返回", style: .default, handler: nil)
            alertController.addAction(action)
            
            self.present(alertController, animated: true, completion: nil)
            
        }

        
    }
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let err = error else{
            
            let characteristicList = service.characteristics
            
            if let characteristics = characteristicList {
                for characteristic in characteristics {
                    switch characteristic.uuid {
                    case MainUUID.read:
                        PeripheralManager.share().peripheralCharMap[peripheral.identifier.uuidString]![.read] = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                    case MainUUID.write:
                        PeripheralManager.share().peripheralCharMap[peripheral.identifier.uuidString]![.write] = characteristic
                    case MainUUID.bigWrite:
                        PeripheralManager.share().peripheralCharMap[peripheral.identifier.uuidString]![.bigWrite] = characteristic
                    case MainUUID.bigRead:
                        PeripheralManager.share().peripheralCharMap[peripheral.identifier.uuidString]![.bigRead] = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                        
                    default:
                        print("otherUUID:\(characteristic.descriptors)")
                    }
                }
            }
            return
        }
        
           // print("ble提供的服务characteristicMap:\(PeripheralManager.share().peripheralCharMap)\n")
            
            //提示是否绑定设备
         DispatchQueue.main.async{
                /*
                //如果已绑定该设备，则直接跳过
                if let UUID = User.shareInstance().bandingUUID , UUID.uuidString == peripheral.identifier.uuidString {
                    self.viewControllerPeripheral(didDiscoverCharacteristicsForService: service, peripheral: peripheral, bindingBle: true)
                    
                    return
                }
                
                self.viewControllerPeripheral(didDiscoverCharacteristicsForService: service, peripheral: peripheral, bindingBle: false)
                
            }
            return*/
        }

        DispatchQueue.main.async{
            /*
            let alertController = UIAlertController(title: "Error", message: "获取设备特征失败", preferredStyle: .alert)
            let action = UIAlertAction(title: "返回", style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
             */
        }

    }
}
