//
//  DeviceLocationSensorViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/16/23.
//

import Foundation
import CoreLocation
import Combine

class DeviceLocationSensorViewModel : ObservableObject {
    private let locationManager: LocationManager = LocationManager()
    
    private var locationSubscription: Cancellable?
    private var isAuthorizedSubscription: Cancellable?
    
    @Published var data: Array<LocationRecord> = Array()
    @Published var isAuthorized: Bool = false
    
    init() {
        isAuthorizedSubscription = locationManager.$isAuthorized.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                isAuthorized = locationManager.isAuthorized
            }
        }
        
        
        locationSubscription = locationManager.$location.combineLatest(locationManager.$heading).sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if let coordinate = locationManager.location?.coordinate,
                   let direction = locationManager.heading?.trueHeading,
                   let speed = locationManager.location?.speed {
                    
                    self.data.append(LocationRecord(
                        speed: Measurement(value: speed, unit: .metersPerSecond),
                        coordinate: Coordinate(
                            latitude: Measurement(value: coordinate.latitude, unit: .degrees),
                            longitude: Measurement(value: coordinate.longitude, unit: .degrees)
                        ),
                        directionInDegrees: Measurement(value: direction.magnitude, unit: .degrees)
                    ))
                }
            }
        }
    }
    
    func startRecording() -> Bool {
        if !locationManager.isAuthorized {
            locationManager.requestAuthorization()
            return false
        }

        locationManager.startLocationRecording()
        
        return true
    }
    
    func stopRecording() {
        locationManager.stopLocationRecording()
    }
}
