//
//  FCBPeripheralDelegate.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/19/24.
//

import Foundation
import CoreBluetooth

public class FCBPeripheralDelegate: NSObject, CBPeripheralDelegate {
    var onDidDiscoverServices: ((CBPeripheral, Error?) -> Void)?
    var onDidWriteValueFor: ((CBPeripheral, CBCharacteristic, Error?) -> Void)?
    var onDidDiscoverCharacteristicsFor: ((CBPeripheral, CBService, Error?) -> Void)?
    var onDidModifyServices: ((CBPeripheral, [CBService]) -> Void)?
    var onDidUpdateName: ((CBPeripheral) -> Void)?
    var onDidUpdateValueFor: ((CBPeripheral, CBCharacteristic, Error?) -> Void)?
    var onIsReady: ((CBPeripheral) -> Void)?
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        onDidDiscoverServices?(peripheral, error)
    }
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        onDidWriteValueFor?(peripheral, characteristic, error)
    }
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        onDidDiscoverCharacteristicsFor?(peripheral, service, error)
    }
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        onDidModifyServices?(peripheral, invalidatedServices)
    }
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        onDidUpdateName?(peripheral)
    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        onDidUpdateValueFor?(peripheral, characteristic, error)
    }
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        onIsReady?(peripheral)
    }
}
