//
//  BLEPeripheralDelegateReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/19/24.
//

import Foundation
import ComposableArchitecture
import CoreBluetooth

@Reducer
struct BLEPeripheralDelegateReducer {
    
    @ObservableState
    struct State: Equatable {
        var peripheralDelegate = FCBPeripheralDelegate()
    }
    
    enum Action: Equatable {
        case initialize
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case didInitialize
            
            case onDidDiscoverServices(CBPeripheral, NSError?)
            case onDidWriteValueFor(CBPeripheral, CBCharacteristic, NSError?)
            case onDidDiscoverCharacteristicsFor(CBPeripheral, CBService, NSError?)
            case onDidModifyServices(CBPeripheral, [CBService])
            case onDidUpdateName(CBPeripheral)
            case onDidUpdateValueFor(CBPeripheral, CBCharacteristic, NSError?)
            case onIsReady(CBPeripheral)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                let peripheralDelegate = state.peripheralDelegate
                
                return .run { send in
                    try await self.onTask(peripheralDelegate, send: send)
                }
            default: break
            }
            return .none
        }
    }
    
    private func onTask(_ peripheralDelegate: FCBPeripheralDelegate, send: Send<Action>) async throws {
        peripheralDelegate.onDidDiscoverServices = { peripheral, error in
            Task {
                await send(.delegate(.onDidDiscoverServices(peripheral, error as NSError?)))
            }
        }
        peripheralDelegate.onDidWriteValueFor = { peripheral, characteristic, error in
            Task {
                await send(.delegate(.onDidWriteValueFor(peripheral, characteristic, error as NSError?)))
            }
        }
        peripheralDelegate.onDidDiscoverCharacteristicsFor = { peripheral, characteristic, error in
            DispatchQueue.main.async {
                send(.delegate(.onDidDiscoverCharacteristicsFor(peripheral, characteristic, error as NSError?)))
            }
        }
        peripheralDelegate.onDidModifyServices = { peripheral, error in
            DispatchQueue.main.async {
                send(.delegate(.onDidModifyServices(peripheral, error)))
            }
        }
        peripheralDelegate.onDidUpdateName = { peripheral in
            DispatchQueue.main.async {
                send(.delegate(.onDidUpdateName(peripheral)))
            }
        }
        peripheralDelegate.onDidUpdateValueFor = { peripheral, characteristic, error in
            Task {
                await send(.delegate(.onDidUpdateValueFor(peripheral, characteristic, error as NSError?)))
            }
        }
        peripheralDelegate.onIsReady = { peripheral in
            DispatchQueue.main.async {
                send(.delegate(.onIsReady(peripheral)))
            }
        }
        
        await send(.delegate(.didInitialize))
        
        while true {
            try await Task.sleep(for: .milliseconds(1000))
        }
    }
    
}
