//
//  LocationManager.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/18/23.
//

import Foundation

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
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 0.5
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error(message: "\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.location = location
            }
        }
    }
}
