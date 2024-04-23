//
//  BLECentralReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/15/24.
//

import Foundation
import ComposableArchitecture
import CoreBluetooth

//extension CBConnectionEvent: Equatable {}

@Reducer
struct BLECentralReducer {
    
    @ObservableState
    struct State {
        var centralDelegate = FCBCentralManagerDelegate()
    }
    
    enum Action {
        case initialize
        case delegate(Delegate)
        
        enum Delegate {
            case didInitialize
            case onCentralManagerDidUpdateState(CBCentralManager)
            case onWillRestoreState(CBCentralManager, [String: Any])
            case onDidDiscoverPeripheral(CBCentralManager, CBPeripheral)
            case onDidConnect(CBCentralManager, CBPeripheral)
            case onDidFailToConnect(CBCentralManager, CBPeripheral, NSError?)
            case onDidDisconnect(CBCentralManager, CBPeripheral, NSError?)
            case onConnectionEventForPeripheral(CBCentralManager, CBConnectionEvent, CBPeripheral)
            case onDidUpdateAndAuthorize(CBCentralManager, CBPeripheral)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                let centralDelegate = state.centralDelegate
                
                return .run { send in
                    centralDelegate.onDidDiscoverPeripheralAdAndRSSI = { centralManager, peripheral, advertisementData, RSSI in
                        print("central discovered")
                        Task { @MainActor in
                            send(.delegate(.onDidDiscoverPeripheral(centralManager, peripheral)))
                        }
                    }
                    centralDelegate.onDidConnect = { centralManager, peripheral in
                        Task { @MainActor in
                            send(.delegate(.onDidConnect(centralManager, peripheral)))
                        }
                    }
                    centralDelegate.onDidFailToConnect = { centralManager, peripheral, error in
                        Task { @MainActor in
                            send(.delegate(.onDidFailToConnect(centralManager, peripheral, error)))
                        }
                    }
                    centralDelegate.onDidDisconnect = { centralManager, peripheral, error in
                        Task { @MainActor in
                            send(.delegate(.onDidDisconnect(centralManager, peripheral, error)))
                        }
                    }
                    
                    while true {
                        try await Task.sleep(nanoseconds: 1_000_000)
                    }
                }
            default: break
            }
            return .none
        }
    }
    
    @MainActor
    func onTask(_ centralDelegate: FCBCentralManagerDelegate, send: Send<Action>) async {
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                centralDelegate.onCentralManagerDidUpdateState = { centralManager in
                    print("central update")
                    send(.delegate(.onCentralManagerDidUpdateState(centralManager)))
                }
            }
        centralDelegate.onWillRestoreState = { centralManager, dict in
            print("central restore")
            Task {
                send(.delegate(.onWillRestoreState(centralManager, dict)))
            }
        }
        centralDelegate.onConnectionEventForPeripheral = { centralManager, event, peripheral in
            DispatchQueue.main.async {
                send(.delegate(.onConnectionEventForPeripheral(centralManager, event, peripheral)))
            }
        }
        centralDelegate.onDidUpdateAndAuthorize = { centralManager, peripheral in
            print("central authed")
            Task {
                await MainActor.run {
                    send(.delegate(.onDidUpdateAndAuthorize(centralManager, peripheral)))
                }
            }
        }
            group.addTask { @MainActor in
            }
        }
    }
}
