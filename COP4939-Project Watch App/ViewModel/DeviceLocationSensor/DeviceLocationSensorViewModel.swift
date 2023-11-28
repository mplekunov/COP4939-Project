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
    
    @Published var data: Array<Location> = Array()
    
    init() {
        locationSubscription = locationManager.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            
            if let coordinate = self.locationManager.location?.coordinate,
               let direction = self.locationManager.location?.course {
                data.append(Location(
                    coordinate: Coordinate(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    ),
                    directionInDegrees: direction.magnitude
                ))
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
