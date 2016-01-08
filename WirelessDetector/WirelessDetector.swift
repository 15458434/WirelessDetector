//
//  WirelessDetector.swift
//  WirelessDetection
//
//  Created by Mark Cornelisse on 07/01/16.
//  Copyright © 2016 Over de muur producties. All rights reserved.
//

import Foundation
import CoreWLAN
import CoreBluetooth

public let WiFiDetectionNotification = "WiFiDetectionNotification"
public let kWifiPowerOnValue = "kWifiPowerOnValue"

public let BluetoothDetectionNotification = "BluetoothDetectionNotification"
public let kBluetoothPowerOnValue = "kBluetoothPowerOnValue"

public enum WifiError: ErrorType, CustomStringConvertible {
    case NoDefaultWiFiInterface
    
    public var description: String {
        switch (self) {
        case .NoDefaultWiFiInterface:
            return "There is no default WiFi Interface"
        }
    }
}

public enum BluetoothError: ErrorType, CustomStringConvertible {
    case NoDefaultBluetoothInterace
    
    public var description: String {
        switch (self) {
        case .NoDefaultBluetoothInterace:
            return "There is no default Bluetooh Interface"
        }
    }
}

public class WirelessDetector: NSObject {
    private let defaultTimerInterval: NSTimeInterval = 1.0
    public var timerInterval: NSTimeInterval? {
        didSet {
            if timer != nil {
                timer!.invalidate()
                if let timerInterval = timerInterval {
                    timer = NSTimer(timeInterval: timerInterval, target: self, selector: "checkWiFiAvailability", userInfo: nil, repeats: true)
                } else {
                    timer = NSTimer(timeInterval: defaultTimerInterval, target: self, selector: "checkWiFiAvailability", userInfo: nil, repeats: true)
                }
                NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
            }
        }
    }
    public private(set) var currentInterface: CWInterface?
    public private(set) var wifiClient = CWWiFiClient.sharedWiFiClient()
    
    private var bluetoothManager: CBCentralManager?
    
    public var isWifiAvailable: Bool {
        return currentInterface?.powerOn() ?? false
    }
    
    public var isBluetoothAvailable: Bool {
        switch (bluetoothManager?.state ?? CBCentralManagerState.Unknown) {
        case CBCentralManagerState.PoweredOn:
            return true
        default:
            return false
        }
    }
    
    private var timer: NSTimer?
    
    public func startMonitoringWifi(intervalChecking intervalChecking: Bool) throws {
        guard let defaultWiFiInterface = wifiClient.interface() else {
            throw WifiError.NoDefaultWiFiInterface
        }
        currentInterface = defaultWiFiInterface
        if intervalChecking {
            if let timerInterval = timerInterval {
                timer = NSTimer(timeInterval: timerInterval, target: self, selector: "checkWiFiAvailability", userInfo: nil, repeats: true)
            } else {
                timer = NSTimer(timeInterval: defaultTimerInterval, target: self, selector: "checkWiFiAvailability", userInfo: nil, repeats: true)
            }
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
        }
        checkWiFiAvailability() 
    }
    
    public func stopMonitoringWifi() {
        timer?.invalidate()
        timer = nil
    }
    
    internal func checkWiFiAvailability() {
        NSNotificationCenter.defaultCenter().postNotificationName(WiFiDetectionNotification, object: self, userInfo: [kWifiPowerOnValue: NSNumber(bool: currentInterface!.powerOn())])
    }
    
    public func startMonitoringBluetooth() {
        if bluetoothManager == nil {
            bluetoothManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        }
        centralManagerDidUpdateState(bluetoothManager!)
    }
    
    public func stopMonitoringBluetooth() {
        bluetoothManager = nil
    }
}

// MARK: CB PeripheralManagerDelegate

extension WirelessDetector: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        switch (central.state) {
        case CBCentralManagerState.PoweredOn:
            NSNotificationCenter.defaultCenter().postNotificationName(BluetoothDetectionNotification, object: self, userInfo: [kBluetoothPowerOnValue: NSNumber(bool: true)])
        case CBCentralManagerState.PoweredOff:
            NSNotificationCenter.defaultCenter().postNotificationName(BluetoothDetectionNotification, object: self, userInfo: [kBluetoothPowerOnValue: NSNumber(bool: false)])
        default:
            NSNotificationCenter.defaultCenter().postNotificationName(BluetoothDetectionNotification, object: self)
        }
    }
}