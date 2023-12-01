//
//  DataCollectorViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation
import Combine

class DataCollectorViewModel : ObservableObject {
    private var deviceMotionSensorModel: DeviceMotionSensorViewModel
    private var deviceLocationSensorModel: DeviceLocationSensorViewModel
    
    private var locationDataSubscription: AnyCancellable?
    private var motionDataSubscription: AnyCancellable?
    private var isLocationAuthorizedSubscription: AnyCancellable?
    
    private let logger: LoggerService
    
    @Published var locations: Array<Location> = Array()
    @Published var motions: Array<MotionData> = Array()
    @Published var collectedData: Array<CollectedData> = Array()
    @Published var isLocationAuthorized: Bool = false
    
    init(
        deviceMotionSensorModel: DeviceMotionSensorViewModel,
        deviceLocationSensorModel: DeviceLocationSensorViewModel
    ) {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        self.deviceMotionSensorModel = deviceMotionSensorModel
        self.deviceLocationSensorModel = deviceLocationSensorModel
        
        isLocationAuthorizedSubscription = deviceLocationSensorModel.$isAuthorized.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLocationAuthorized = deviceLocationSensorModel.isAuthorized
            }
        }
        
        locationDataSubscription = deviceLocationSensorModel.$data.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.locations = deviceLocationSensorModel.data
                
                let locationData = deviceLocationSensorModel.data.last ?? Location()
                let motionData = deviceMotionSensorModel.data.last ?? MotionData()
                
                let collectedData = CollectedData(locationData: locationData, motionData: motionData)
                self.collectedData.append(collectedData)
            }
        }
        
        motionDataSubscription = deviceMotionSensorModel.$data.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.motions = deviceMotionSensorModel.data
            }
        }
    }
    
    func startDataCollection() -> Bool {
        if deviceLocationSensorModel.startRecording() {
            deviceMotionSensorModel.startRecording()
            return true
        }
        
        return false
    }
    
    func stopDataCollection() {
        deviceMotionSensorModel.stopRecording()
        deviceLocationSensorModel.stopRecording()
    }
    
    func clearData() {
        locations.removeAll()
        motions.removeAll()
        collectedData.removeAll()
    }
}
