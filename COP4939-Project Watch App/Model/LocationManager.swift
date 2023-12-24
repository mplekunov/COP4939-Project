//
//  LocationManager.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/18/23.
//

import Foundation

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var error: LocationManagerError?
    @Published var isRecording: Bool?
    
    private let logger: LoggerService
    
    static let instance: LocationManager = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    private override init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        super.init()
        
        configure()
        checkPermissions()
    }
    
    private func configure() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 0.5
    }
    
    private func set(error: LocationManagerError?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.error = error
        }
    }
    
    func checkPermissions() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted:
            set(error: .RestrictedAuthorization)
        case .denied:
            set(error: .DeniedAuthorization)
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        @unknown default:
            set(error: .UnknownAuthorization)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            checkPermissions()
        }
    }
    
    func startLocationRecording() {
        guard error == nil else { return }
        
        locationManager.startUpdatingLocation()
        isRecording = true
    }
    
    func stopLocationRecording() {
        locationManager.stopUpdatingLocation()
        isRecording = false
    }
}

extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.location = location
                objectWillChange.send()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error(message: "\(error)")
    }
}
