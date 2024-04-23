//
//  BLEPeripheralManagerReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/15/24.
//

import Foundation
import ComposableArchitecture
import CoreBluetooth
import CoreLocation

let serviceUuid = "D443100E-AF9E-4513-8484-72E2A4677E57"
let gameInfoUuid = "7B0C9766-7A56-4C40-BE4D-8ABB6E43548F"
let playerInfoUuid = "EAD6B721-F679-4E44-BE7B-3AC394273CD9"
@Reducer
struct BLEPeripheralManagerReducer {
    
    @ObservableState
    struct State: Equatable {
        var peripheralManager: CBPeripheralManager = CBPeripheralManager(delegate: nil, queue: DispatchQueue(label: "BLE-adv"))//, options: [CBPeripheralManagerOptionRestoreIdentifierKey: "ble-adv"])
        var peripheralDelegateState = BLEPeripheralManagerDelegateReducer.State()
        var game: Game
        var isInitialized = false
    }
    
    enum Action {
        case initialize
        case startAdvertising
        case stopAdvertising
        case peripheralDelegate(BLEPeripheralManagerDelegateReducer.Action)
        case delegate(Delegate)
        
        enum Delegate {
            case didInitialize
            case didAdd(Character)
        }
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.peripheralDelegateState, action: \.peripheralDelegate) {
            BLEPeripheralManagerDelegateReducer()
        }
        Reduce { state, action in
            switch action {
            case .initialize:
                state.peripheralManager.delegate = state.peripheralDelegateState.peripheralDelegate
                return .send(.peripheralDelegate(.initialize))
            case .startAdvertising:
                state.peripheralManager.stopAdvertising()
                state.peripheralManager.removeAllServices()
                
                let gameInfoCharacteristic = CBMutableCharacteristic(type: CBUUID(string: gameInfoUuid), properties: .read, value: try? Current.apiJsonEncoder.encode(state.game), permissions: .readable)
                
                let playerCharacteristic = CBMutableCharacteristic(type: CBUUID(string: playerInfoUuid), properties: .writeWithoutResponse, value: nil, permissions: .writeable)
                
                let service = CBMutableService(type: CBUUID(string: serviceUuid), primary: true)
                service.characteristics = [gameInfoCharacteristic, playerCharacteristic]
                state.peripheralManager.add(service)
                state.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service.uuid]])
            case .stopAdvertising:
                state.peripheralManager.stopAdvertising()
                
            case .peripheralDelegate(.delegate(.onDidUpdateState(let manager))):
                if manager.state == .poweredOn {
                    state.isInitialized = state.peripheralManager != nil && state.peripheralDelegateState.peripheralDelegate != nil
                    if state.isInitialized {
                        return .send(.delegate(.didInitialize))
                    }
                }
            case .peripheralDelegate(.delegate(.didInitialize)):
                state.peripheralManager.delegate = state.peripheralDelegateState.peripheralDelegate //(label: "BLE-adv"), options: [:])
                return .send(.startAdvertising)
            case .peripheralDelegate(.delegate(.onDidAddService(let manager, let service, _))):
                manager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service.uuid]])
            case .peripheralDelegate(.delegate(.onDidReceiveRead(_, let request))):
                break
            case .peripheralDelegate(.delegate(.onDidReceiveWrite(_, let requests))):
                if let request = requests.first {
                    if let data = request.value, let cardCharacter = try? Current.apiJsonDecoder.decode(CardCharacter.self, from: data) {
                        return .send(.delegate(.didAdd(Character.fromCard(cardCharacter))))
                    }
                }
            case .peripheralDelegate(.delegate(.onDidSubscribeToCharacteristic(_, _, _))):
                break
            case .peripheralDelegate(.delegate(.onPeripheralManagerReady(_))):
                break
            case .peripheralDelegate(_): break
            case .delegate(_): break
            }
            return .none
        }
    }
}
