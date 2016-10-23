//
//  ViewController.swift
//  CoreBluetoothTest
//
//  Created by chocoffee on 2016/10/19.
//  Copyright © 2016年 chocoffee, All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralManagerDelegate, UITextFieldDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var peripheralManager: CBPeripheralManager!
    
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var messageView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //  接続状況が変わるたびに呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print ("state: \(central.state)")
    }
    
    //  スキャン開始
    @IBAction func startScan(_ sender: UIButton) {
        //  2.3
        //  centralManager.scanForPeripheralsWithServices(nil, options: nil)
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    //  スキャン結果を取得
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        self.centralManager.connect(self.peripheral, options: nil)
    }

    //  スキャン終了
    @IBAction func stopScan(_ sender: UIButton) {
        centralManager.stopScan()
    }

    
    //  接続成功時に呼ばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connect success!")
    }
    
    //  接続失敗時に呼ばれる
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Connect failed...")
    }
    @IBAction func sendMessage(_ sender: UIButton) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    //  ペリフェラルのStatusが変化した時に呼ばれる
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("periState\(peripheral.state)")
    }
    @IBAction func startAdvertite(_ sender: UIButton) {
        let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        let serviceUUID = CBUUID(string: "0000")
        let service = CBMutableService(type: serviceUUID, primary: true)
        let charactericUUID = CBUUID(string: "0001")
        let characteristic = CBMutableCharacteristic(type: charactericUUID, properties: CBCharacteristicProperties.read, value: nil, permissions: CBAttributePermissions.readable)
        service.characteristics = [characteristic]
        self.peripheralManager.add(service)
        peripheralManager.startAdvertising(advertisementData)
    }
    
    //  サービス追加結果の取得
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            print("Service Add Failed...")
            return
        }
        print("Service Add Sucsess!")
    }
    
    //  アドバタイズ開始処理の結果を取得
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("***Advertising ERROR")
            return
        }
        print("Advertising success")
    }
    
    //  アドバタイズ終了
    @IBAction func stopArvertisement(_ sender: UIButton) {
        peripheralManager.stopAdvertising()
    }
    
    //  service検索開始
    @IBAction func getService(_ sender: UIButton) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    //  service検索結果取得
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else{
            print("error")
            return
        }
        print("\(services.count)個のサービスを発見。\(services)")
        
        //  サービスを見つけたらすぐにキャラクタリスティックを取得
        for obj in services {
            peripheral.discoverCharacteristics(nil, for: obj)
        }
    }
    
    //  キャラクタリスティック検索結果取得
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            print("\(characteristics.count)個のキャラクタリスティックを発見。\(characteristics)")
        }
    }
}

