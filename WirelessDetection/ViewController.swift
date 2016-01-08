//
//  ViewController.swift
//  WirelessDetection
//
//  Created by Mark Cornelisse on 07/01/16.
//  Copyright © 2016 Over de muur producties. All rights reserved.
//

import Cocoa
import WirelessDetector

class ViewController: NSViewController {
    // MARK: Properties
    let wirelessD = WirelessDetector()
    
    // MARK: IB Outlets
    @IBOutlet var wifiLabel: NSTextField!
    @IBOutlet var wifiPowerOnValue: NSTextField!
    @IBOutlet var bluetoothLabel: NSTextField!
    @IBOutlet var bluetoothPowerOnValue: NSTextField!
    
    // MARK: New in this class
    
    // MARK: Inherited from super
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        wifiLabel.stringValue = "Wifi State"
        wifiPowerOnValue.stringValue = ""
        bluetoothLabel.stringValue = "Bluetooth State"
        bluetoothPowerOnValue.stringValue = ""
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "wifiStateChanged:", name: WiFiDetectionNotification, object: wirelessD)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bluetoothStateChanged:", name: BluetoothDetectionNotification, object: wirelessD)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        do {
            try wirelessD.startMonitoringWifi(intervalChecking: true)
        } catch {
            print("Error starting Wifi Power notifications: \(error)")
        }
        
        wirelessD.startMonitoringBluetooth()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        wirelessD.stopMonitoringWifi()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: Notification
    
    internal func wifiStateChanged(notification: NSNotification) {
        if (notification.userInfo![kWifiPowerOnValue] as! NSNumber).boolValue {
            wifiPowerOnValue.stringValue = "ON"
        } else {
            wifiPowerOnValue.stringValue = "OFF"
        }
    }
    
    internal func bluetoothStateChanged(notification: NSNotification) {
        let isPoweredOn = (notification.userInfo?[kBluetoothPowerOnValue] as? NSNumber)?.boolValue ?? false
        if isPoweredOn {
            bluetoothPowerOnValue.stringValue = "ON"
        } else {
            bluetoothPowerOnValue.stringValue = "OFF"
        }
    }
}

