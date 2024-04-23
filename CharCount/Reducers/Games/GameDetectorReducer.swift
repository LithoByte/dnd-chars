//
//  GameDetectorReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/18/24.
//

import Foundation
import ComposableArchitecture
import CoreBluetooth

@Reducer
struct GameDetectorReducer {
    
    @ObservableState
    struct State {
        var id = Current.uuid()
        var status: String = "Uninitialized"
        var centralManager: CBCentralManager = CBCentralManager(delegate: nil, queue: DispatchQueue(label: "BLE-Q"))//, options: [CBCentralManagerOptionShowPowerAlertKey: true, CBCentralManagerOptionRestoreIdentifierKey: Current.uuid().uuidString])
        var centralDelegateState = BLECentralReducer.State()
        var peripheralDelegateState = BLEPeripheralDelegateReducer.State()
        var currentPeripheral: CBPeripheral?
        var gameDevices: [Game.ID: CBPeripheral] = [:]
        var chosenCharacter: Character?
    }
    
    enum Action {
        case initialize
        case startDetecting
        case stopDetecting
        case join(Game, Character)
        case centralDelegate(BLECentralReducer.Action)
        case peripheralDelegate(BLEPeripheralDelegateReducer.Action)
        case delegate(Delegate)
        
        enum Delegate {
            case didInitialize
            case didDetectGames([Game])
        }
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.peripheralDelegateState, action: \.peripheralDelegate) {
            BLEPeripheralDelegateReducer()
        }
        Scope(state: \.centralDelegateState, action: \.centralDelegate) {
            BLECentralReducer()
        }
        Reduce { state, action in
            switch action {
            case .initialize:
                state.status = "initializing"
                state.centralManager.delegate = state.centralDelegateState.centralDelegate
                return .run { send in
                    await send(.peripheralDelegate(.initialize))
                    await send(.centralDelegate(.initialize))
                    await send(.centralDelegate(.delegate(.didInitialize)))
                }
            case .join(let game, let character):
                if let peripheral = state.gameDevices[game.id] {
                    state.chosenCharacter = character
                    state.centralManager.connect(peripheral)
                }
            case .startDetecting:
                state.status = "detecting"
                state.centralManager.scanForPeripherals(withServices: [CBUUID(string: serviceUuid)])
            case .stopDetecting:
                state.centralManager.stopScan()
            case .centralDelegate(.delegate(.didInitialize)):
                state.status = "creating central"
                if state.centralManager.state == .poweredOn {
                    state.status = "delegated, powered on, scanning"
                    state.centralManager.scanForPeripherals(withServices: [CBUUID(string: serviceUuid)])
                }
            case .centralDelegate(.delegate(.onCentralManagerDidUpdateState(let central))):
                state.status = "updating central state"
                if central.state == .poweredOn {
                    state.status = "powered on, scanning"
                    state.centralManager.scanForPeripherals(withServices: [CBUUID(string: serviceUuid)])
                }
            case .centralDelegate(.delegate(.onWillRestoreState(let central, _))):
                if central.state == .poweredOn {
                    state.centralManager.scanForPeripherals(withServices: [CBUUID(string: serviceUuid)])
                } else {
                    
                }
            case .centralDelegate(.delegate(.onDidDiscoverPeripheral(let manager, let peripheral))):
                state.status = "discovered peripheral"
                if let current = state.currentPeripheral, current.state != .connecting && current.state != .connected {
                    state.status = "connecting"
                    state.centralManager.connect(peripheral)
                    state.currentPeripheral = peripheral
                } else if state.currentPeripheral == nil {
                    state.status = "connecting"
                    state.centralManager.connect(peripheral)
                    state.currentPeripheral = peripheral
                }
            case .centralDelegate(.delegate(.onDidConnect(_, let peripheral))):
                state.status = "connected"
                peripheral.delegate = state.peripheralDelegateState.peripheralDelegate
                peripheral.discoverServices([CBUUID(string: serviceUuid)])
            case .centralDelegate(.delegate(.onConnectionEventForPeripheral(_, let event, let peripheral))):
                state.status = "event..."
                if event == .peerConnected {
                    state.status = "event connected"
                    peripheral.delegate = state.peripheralDelegateState.peripheralDelegate
                    peripheral.discoverServices([CBUUID(string: serviceUuid)])
                }
            case .peripheralDelegate(.delegate(.onDidDiscoverServices(let peripheral, _))):
                state.status = "discovered \(peripheral.services?.count ?? 0) services"
                if let services = peripheral.services?.filter({ $0.uuid == CBUUID(string: serviceUuid) }) {
                    if let _ = state.chosenCharacter {
                        for service in services {
                            peripheral.discoverCharacteristics([CBUUID(string: playerInfoUuid)], for: service)
                        }
                    } else {
                        for service in services {
                            peripheral.discoverCharacteristics([CBUUID(string: gameInfoUuid)], for: service)
                        }
                    }
                } else {
                    state.status = "discovered services... but not the ones we want?"
                }
            case .peripheralDelegate(.delegate(.onDidDiscoverCharacteristicsFor(let peripheral, let service, _))):
                if let char = service.characteristics?.first(where: { $0.uuid == CBUUID(string: playerInfoUuid) }), let character = state.chosenCharacter {
                    if peripheral.canSendWriteWithoutResponse {
                        print(peripheral.maximumWriteValueLength(for: .withoutResponse))
                        peripheral.writeValue(try! Current.apiJsonEncoder.encode(character.toCard()), for: char, type: CBCharacteristicWriteType.withoutResponse)
                        state.chosenCharacter = nil
                    }
                } else if let chars = service.characteristics?.filter({ $0.uuid == CBUUID(string: gameInfoUuid) }) {
                    for char in chars {
                        peripheral.readValue(for: char)
                    }
                }
            case .peripheralDelegate(.delegate(.onDidUpdateValueFor(let peripheral, let characteristic, _))):
                if let data = characteristic.value, var game = try? Current.apiJsonDecoder.decode(Game.self, from: data) {
                    state.gameDevices[game.id] = peripheral
                    state.currentPeripheral = nil
                    game.isCreator = false
                    return .send(.delegate(.didDetectGames([game])))
                }
            case .centralDelegate(_): break
            case .peripheralDelegate(_): break
            case .delegate(_): break
            }
            return .none
        }
    }
}
