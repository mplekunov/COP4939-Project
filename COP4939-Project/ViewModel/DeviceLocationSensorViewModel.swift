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
    
    @Published public private(set) var lastLocation: LocationRecord?
    @Published public private(set) var error: String?
    @Published public private(set) var isRecording: Bool?
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        locationManager.$error
            .receive(on: DispatchQueue.main)
            .compactMap { error in
                guard let error = error else { return nil }
                
                return error.description
            }
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
