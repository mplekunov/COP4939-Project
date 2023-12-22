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
    
    private var locationSubscription: Cancellable?
    private var isAuthorizedSubscription: Cancellable?
    
    @Published var lastLocation: LocationRecord?
    @Published var error: LocationManagerError?
    @Published var isRecording = false
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        isAuthorizedSubscription = locationManager.$error.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                error = locationManager.error
            }
        }
        
        locationSubscription = locationManager.$location.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if let coordinate = locationManager.location?.coordinate,
                   let speed = locationManager.location?.speed {
                    
                    self.lastLocation = LocationRecord(
                        speed: Measurement(value: speed, unit: .metersPerSecond),
                        coordinate: Coordinate(
                            latitude: Measurement(value: coordinate.latitude, unit: .degrees),
                            longitude: Measurement(value: coordinate.longitude, unit: .degrees)
                        )
                    )
                }
            }
        }
    }
    
    func startRecording() {
        locationManager.startLocationRecording()
        isRecording = true
    }
    
    func stopRecording() {
        locationManager.stopLocationRecording()
        isRecording = false
    }
}
