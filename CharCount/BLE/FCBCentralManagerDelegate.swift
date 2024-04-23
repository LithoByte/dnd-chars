//
//  FCBCentralManagerDelegate.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/15/24.
//

import Foundation
import CoreBluetooth

open class FCBCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
  /**
   This class implements CBCentralManagerDelegate.
   */
  public var onCentralManagerDidUpdateState: ((CBCentralManager) -> Void)? = nil
  public var onWillRestoreState: ((CBCentralManager, [String:Any]) -> Void)? = nil
  public var onDidDiscoverPeripheralAdAndRSSI: ((CBCentralManager, CBPeripheral, [String:Any], NSNumber) -> Void)? = nil
  public var onDidConnect: ((CBCentralManager, CBPeripheral) -> Void)? = nil
  public var onDidFailToConnect: ((CBCentralManager, CBPeripheral, NSError?) -> Void)? = nil
  public var onDidDisconnect: ((CBCentralManager, CBPeripheral, NSError?) -> Void)? = nil
  public var onConnectionEventForPeripheral: ((CBCentralManager, CBConnectionEvent, CBPeripheral) -> Void)? = nil
  public var onDidUpdateAndAuthorize: ((CBCentralManager, CBPeripheral) -> Void)? = nil
  
  
  @available(iOS 5.0, *)
  open func centralManagerDidUpdateState(_ central: CBCentralManager) {
    onCentralManagerDidUpdateState?(central)
  }
  
  @available(iOS 5.0, *)
  open func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
    onWillRestoreState?(central, dict)
  }
  
  @available(iOS 5.0, *)
    open func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async { [weak self] in
            self?.onDidDiscoverPeripheralAdAndRSSI?(central, peripheral, advertisementData, RSSI)
    }
  }
  
  @available(iOS 5.0, *)
  open func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    onDidConnect?(central, peripheral)
  }
  
  @available(iOS 5.0, *)
  open func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
      onDidFailToConnect?(central, peripheral, error as NSError?)
  }
  
  @available(iOS 5.0, *)
  open func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
      onDidDisconnect?(central, peripheral, error as NSError?)
  }
  
  @available(iOS 13.0, *)
  open func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
    onConnectionEventForPeripheral?(central, event, peripheral)
  }
  
  @available(iOS 13.0, *)
  open func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
    onDidUpdateAndAuthorize?(central, peripheral)
  }
  
}
