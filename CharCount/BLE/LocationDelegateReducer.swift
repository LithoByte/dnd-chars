//
//  LocationDelegateReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/18/24.
//

import Foundation
import ComposableArchitecture
import CoreLocation

@Reducer
struct LocationDelegateReducer {
    
    @ObservableState
    struct State: Equatable {
        var locationDelegate: FCLLocationManagerDelegate?
    }
    
    enum Action {
        case initialize
        case delegate(Delegate)
        
        enum Delegate {
            case didInitialize
            
            case onDidRangeBeaconsInRegion(CLLocationManager, [CLBeacon], CLBeaconRegion)
            case onDidRangeBeaconsSatisfying(CLLocationManager, [CLBeacon], CLBeaconIdentityConstraint)
            
            case onDidUpdateLocations(CLLocationManager, [CLLocation])
            case onDidUpdateHeading(CLLocationManager, CLHeading)
            case onLocationmanagerShouldDisplayHeadingCalibration(CLLocationManager)
            case onDidDetermineStateForRegion(CLLocationManager, CLRegionState, CLRegion)
            case onRangingBeaconsDidFailForRegionWithError(CLLocationManager, CLBeaconRegion, Error)
            case onDidEnterRegion(CLLocationManager, CLRegion)
            case onDidExitRegion(CLLocationManager, CLRegion)
            case onDidFailWithError(CLLocationManager, Error)
            case onMonitoringDidFailForRegionWithError(CLLocationManager, CLRegion?, Error)
            case onDidChangeAuthorizationStatus(CLLocationManager, CLAuthorizationStatus)
            case onDidStartMonitoringForRegion(CLLocationManager, CLRegion)
            case onDidPauseLocationUpdates(CLLocationManager)
            case onDidResumeLocationUpdates(CLLocationManager)
            case onDidDeferLocationUpdatesWithError(CLLocationManager, Error?)
            case onDidVisit(CLLocationManager, CLVisit)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                let delegate = FCLLocationManagerDelegate()
                state.locationDelegate = delegate
                
                return .run { send in
                    await onTask(delegate, send: send)
                    await send(.delegate(.didInitialize))
                }
            default: break
            }
            return .none
        }
    }
    
    private func onTask(_ locationDelegate: FCLLocationManagerDelegate, send: Send<Action>) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                locationDelegate.onDidRangeBeaconsInRegion = { send(.delegate(.onDidRangeBeaconsInRegion($0, $1, $2))) }
                locationDelegate.onDidRangeBeaconsSatisfying = { send(.delegate(.onDidRangeBeaconsSatisfying($0, $1, $2))) }
                
                locationDelegate.onDidUpdateLocations = { send(.delegate(.onDidUpdateLocations($0, $1))) }
                locationDelegate.onDidUpdateHeading = { send(.delegate(.onDidUpdateHeading($0, $1))) }
                locationDelegate.onDidDetermineStateForRegion = { send(.delegate(.onDidDetermineStateForRegion($0, $1, $2))) }
                locationDelegate.onDidRangeBeaconsInRegion = { send(.delegate(.onDidRangeBeaconsInRegion($0, $1, $2))) }
                locationDelegate.onRangingBeaconsDidFailForRegionWithError = { send(.delegate(.onRangingBeaconsDidFailForRegionWithError($0, $1, $2))) }
                locationDelegate.onDidEnterRegion = { send(.delegate(.onDidEnterRegion($0, $1))) }
                locationDelegate.onDidExitRegion = { send(.delegate(.onDidExitRegion($0, $1))) }
                locationDelegate.onDidFailWithError = { send(.delegate(.onDidFailWithError($0, $1))) }
                locationDelegate.onMonitoringDidFailForRegionWithError = { send(.delegate(.onMonitoringDidFailForRegionWithError($0, $1, $2))) }
                locationDelegate.onDidChangeAuthorizationStatus = { send(.delegate(.onDidChangeAuthorizationStatus($0, $1))) }
                locationDelegate.onDidStartMonitoringForRegion = { send(.delegate(.onDidStartMonitoringForRegion($0, $1))) }
                locationDelegate.onDidPauseLocationUpdates = { send(.delegate(.onDidPauseLocationUpdates($0))) }
                locationDelegate.onDidResumeLocationUpdates = { send(.delegate(.onDidResumeLocationUpdates($0))) }
                locationDelegate.onDidDeferLocationUpdatesWithError = { send(.delegate(.onDidDeferLocationUpdatesWithError($0, $1))) }
                locationDelegate.onDidVisit = { send(.delegate(.onDidVisit($0, $1))) }
            }
        }
    }
}
