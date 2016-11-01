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
    
    let godManager = GodManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        config()
        createContents()
    }

    private func config(){
        
        godManager.delegate = self
    }
    
    private func createContents(){
     
        print("end createContents")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        godManager.startScan()
    }
}

//MARK:- GodManager 代理实现
extension ViewController: GodManagerDelegate{
    func godManager(didDiscoverPeripheral peripheral: CBPeripheral, withRSSI RSSI: NSNumber, peripheralName name: String){
        print(name)
        print(peripheral)
        print(RSSI)
    }
}
