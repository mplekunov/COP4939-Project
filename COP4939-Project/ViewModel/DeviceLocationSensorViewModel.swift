//
//  DeviceLocationSensorViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/18/23.
//

import Foundation
import Combine

class DeviceLocationSensorViewModel : ObservableObject {
    private let locationManager = LocationManager.instance
    
    private let logger: LoggerService
    
    @Published var lastLocation: LocationRecord?
    @Published var error: LocationManagerError?
    @Published var isRecording: Bool?
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        locationManager.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)
        
        locationManager.$location
            .receive(on: DispatchQueue.main)
            .compactMap { location in
                guard let location = location else { return nil }
                
                let coordinate = location.coordinate
                let speed = location.speed
                
                return LocationRecord(
                    speed: Measurement(value: speed, unit: .metersPerSecond),
                    coordinate: Coordinate(
                        latitude: Measurement(value: coordinate.latitude, unit: .degrees),
                        longitude: Measurement(value: coordinate.longitude, unit: .degrees)
                    )
                )
            }
            .assign(to: &$lastLocation)
        
        locationManager.$isRecording
            .receive(on: DispatchQueue.main)
            .assign(to: &$isRecording)
    }
    
    func startRecording() {
        locationManager.startLocationRecording()
    }
    
    func stopRecording() {
        locationManager.stopLocationRecording()
    }
}
