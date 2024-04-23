//
//  BLEPeripheralManagerDelegateReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/15/24.
//

import Foundation
import ComposableArchitecture
import CoreBluetooth

@Reducer
struct BLEPeripheralManagerDelegateReducer {
    
    @ObservableState
    struct State: Equatable {
        var peripheralDelegate = FCBPeripheralManagerDelegate()
    }
    
    enum Action {
        case initialize
        case delegate(Delegate)
        
        enum Delegate {
            case didInitialize
            
            case onDidUpdateState(CBPeripheralManager)
            case onWillRestoreState(CBPeripheralManager, [String:Any])
            case onDidStartAdvertising(CBPeripheralManager, Error?)
            case onDidAddService(CBPeripheralManager, CBService, Error?)
            case onDidSubscribeToCharacteristic(CBPeripheralManager, CBCentral, CBCharacteristic)
            case onDidUnsubscribeFromCharacteristic(CBPeripheralManager, CBCentral, CBCharacteristic)
            case onDidReceiveRead(CBPeripheralManager, CBATTRequest)
            case onDidReceiveWrite(CBPeripheralManager, [CBATTRequest])
            case onPeripheralManagerReady(CBPeripheralManager)
            case onDidPublishL2CAPChannel(CBPeripheralManager, CBL2CAPPSM, Error?)
            case onDidUnpublishL2CAPChannel(CBPeripheralManager, CBL2CAPPSM, Error?)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                let peripheralDelegate = state.peripheralDelegate
                
                return .run { send in
                    await self.onTask(peripheralDelegate, send: send)
                    await send(.delegate(.didInitialize))
                    
                    while true {
                        try await Task.sleep(for: .milliseconds(1000))
                    }
                }
            default: break
            }
            return .none
        }
    }
    
    private func onTask(_ peripheralDelegate: FCBPeripheralManagerDelegate, send: Send<Action>) async {
        peripheralDelegate.onDidUpdateState = { peripheralManager in
            Task {
                await send(.delegate(.onDidUpdateState(peripheralManager)))
            }
        }
        peripheralDelegate.onWillRestoreState = { peripheralManager, dict in
            Task {
                await send(.delegate(.onWillRestoreState(peripheralManager, dict)))
            }
        }
        peripheralDelegate.onDidStartAdvertising = { peripheralManager, error in
            Task {
                await send(.delegate(.onDidStartAdvertising(peripheralManager, error)))
            }
        }
        peripheralDelegate.onDidAddService = { peripheralManager, service, error in
            Task {
                await send(.delegate(.onDidAddService(peripheralManager, service, error)))
            }
        }
        peripheralDelegate.onDidSubscribeToCharacteristic = { peripheralManager, central, characteristic in
            Task {
                await send(.delegate(.onDidSubscribeToCharacteristic(peripheralManager, central, characteristic)))
            }
        }
        peripheralDelegate.onDidUnsubscribeFromCharacteristic = { peripheralManager, central, characteristic in
            Task {
                await send(.delegate(.onDidUnsubscribeFromCharacteristic(peripheralManager, central, characteristic)))
            }
        }
        peripheralDelegate.onDidReceiveRead = { peripheralManager, request in
            Task {
                await send(.delegate(.onDidReceiveRead(peripheralManager, request)))
            }
        }
        peripheralDelegate.onDidReceiveWrite = { peripheralManager, requests in
            Task {
                await send(.delegate(.onDidReceiveWrite(peripheralManager, requests)))
            }
        }
        peripheralDelegate.onPeripheralManagerReady = { peripheralManager in
            Task {
                await send(.delegate(.onPeripheralManagerReady(peripheralManager)))
            }
        }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
//                peripheralDelegate.onDidPublishL2CAPChannel = { peripheralManager in
//                    DispatchQueue.main.async {
//                        send(.delegate(.onDidPublishL2CAPChannel(peripheralManager, $1, $2)))
//                    }
//                }
//                peripheralDelegate.onDidUnpublishL2CAPChannel = { peripheralManager in
//                    DispatchQueue.main.async {
//                        send(.delegate(.onDidUnpublishL2CAPChannel(peripheralManager, $1, $2)))
//                    }
//                }
            }
        }
    }
}
