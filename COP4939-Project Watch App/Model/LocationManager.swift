//
//  LocationManager.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/18/23.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var isAuthorized: Bool = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
    }
    
    func requestAuthorization() {
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        isAuthorized = locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    func startLocationRecording() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationRecording() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
        }
    }
}
