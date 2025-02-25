//
//  FCLLocationManagerDelegate.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/18/24.
//

import Foundation
import CoreLocation

public class FCLLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var onDidRangeBeaconsSatisfying: ((CLLocationManager, [CLBeacon], CLBeaconIdentityConstraint) -> Void)?
    var onDidFailRangingBeaconsSatisfying: ((CLLocationManager, CLBeaconIdentityConstraint, Error) -> Void)?
    
    public var onDidUpdateLocations: ((CLLocationManager, [CLLocation]) -> Void)? = nil
    public var onDidUpdateHeading: ((CLLocationManager, CLHeading) -> Void)? = nil
    public var onLocationmanagerShouldDisplayHeadingCalibration: ((CLLocationManager) -> Bool)? = nil
    public var onDidDetermineStateForRegion: ((CLLocationManager, CLRegionState, CLRegion) -> Void)? = nil
    public var onDidRangeBeaconsInRegion: ((CLLocationManager, [CLBeacon], CLBeaconRegion) -> Void)? = nil
    public var onRangingBeaconsDidFailForRegionWithError: ((CLLocationManager, CLBeaconRegion, Error) -> Void)? = nil
    public var onDidEnterRegion: ((CLLocationManager, CLRegion) -> Void)? = nil
    public var onDidExitRegion: ((CLLocationManager, CLRegion) -> Void)? = nil
    public var onDidFailWithError: ((CLLocationManager, Error) -> Void)? = nil
    public var onMonitoringDidFailForRegionWithError: ((CLLocationManager, CLRegion?, Error) -> Void)? = nil
    public var onDidChangeAuthorizationStatus: ((CLLocationManager, CLAuthorizationStatus) -> Void)? = nil
    public var onDidStartMonitoringForRegion: ((CLLocationManager, CLRegion) -> Void)? = nil
    public var onDidPauseLocationUpdates: ((CLLocationManager) -> Void)? = nil
    public var onDidResumeLocationUpdates: ((CLLocationManager) -> Void)? = nil
    public var onDidDeferLocationUpdatesWithError: ((CLLocationManager, Error?) -> Void)? = nil
    public var onDidVisit: ((CLLocationManager, CLVisit) -> Void)? = nil
    
    @available(iOS 6.0, *)
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        onDidUpdateLocations?(manager, locations)
    }
    
    @available(iOS 3.0, *)
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        onDidUpdateHeading?(manager, newHeading)
    }
    
    @available(iOS 3.0, *)
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return onLocationmanagerShouldDisplayHeadingCalibration?(manager) ?? true
    }
    @available(iOS 7.0, *)
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        onDidDetermineStateForRegion?(manager, state, region)
    }
    @available(iOS, introduced: 7.0, deprecated: 13.0)
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        onDidRangeBeaconsInRegion?(manager, beacons, region)
    }
    @available(iOS, introduced: 7.0, deprecated: 13.0)
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        onRangingBeaconsDidFailForRegionWithError?(manager, region, error)
    }
    @available(iOS 4.0, *)
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        onDidEnterRegion?(manager, region)
    }
    @available(iOS 4.0, *)
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        onDidExitRegion?(manager, region)
    }
    @available(iOS 2.0, *)
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onDidFailWithError?(manager, error)
    }
    @available(iOS 4.0, *)
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        onMonitoringDidFailForRegionWithError?(manager, region, error)
    }
    @available(iOS 4.2, *)
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        onDidChangeAuthorizationStatus?(manager, status)
    }
    @available(iOS 5.0, *)
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        onDidStartMonitoringForRegion?(manager, region)
    }
    @available(iOS 6.0, *)
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        onDidPauseLocationUpdates?(manager)
    }
    
    @available(iOS 6.0, *)
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        onDidResumeLocationUpdates?(manager)
    }
    
    
    @available(iOS 6.0, *)
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        onDidDeferLocationUpdatesWithError?(manager, error)
    }
    @available(iOS 8.0, *)
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        onDidVisit?(manager, visit)
    }
    
    @available(iOS 13.0, *)
    public func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        onDidRangeBeaconsSatisfying?(manager, beacons, beaconConstraint)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        onDidFailRangingBeaconsSatisfying?(manager, beaconConstraint, error)
    }
}
