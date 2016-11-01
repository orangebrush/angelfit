//
//  ViewController.swift
//  AngelFitSample
//
//  Created by ganyi on 2016/11/1.
//  Copyright © 2016年 ganyi. All rights reserved.
//

import UIKit
import AngelFit
import CoreBluetooth
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        config()
        createContents()
    }

    private func config(){
        
    }
    
    private func createContents(){
        
        let godManger = GodManager()
        godManger.scanDevice()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

extension ViewController:GodManagerDelegate{
   func godManager(didDiscoverPeripheral peripheral: CBPeripheral, withRSSI RSSI: NSNumber, peripheralName name: String){
       print(name);
    }
}
