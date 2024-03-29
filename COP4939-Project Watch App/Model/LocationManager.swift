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
    
    private let logger: LoggerService
    
    private let locationManager = CLLocationManager()
    
    override init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
    }
    
    func requestAuthorization() {
        self.isAuthorized = self.locationManager.authorizationStatus == .authorizedWhenInUse
        
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.isAuthorized = self.locationManager.authorizationStatus == .authorizedWhenInUse
        }
    }
    
    func startLocationRecording() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationRecording() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.location = location
            }
        }
    }
}
