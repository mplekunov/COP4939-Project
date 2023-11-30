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
    
    @Published var data: Array<Location> = Array()
    @Published var isAuthorized: Bool = false
    
    init() {
        isAuthorizedSubscription = locationManager.$isAuthorized.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isAuthorized = self.locationManager.isAuthorized
            }
        }
        
        locationSubscription = locationManager.$location.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let coordinate = self.locationManager.location?.coordinate,
                   let direction = self.locationManager.location?.course {
                    
                    self.data.append(Location(
                        coordinate: Coordinate(
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude
                        ),
                        directionInDegrees: direction.magnitude
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
