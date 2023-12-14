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
    
    @Published var locationRecords: Array<LocationRecord> = Array()
    @Published var motionRecords: Array<MotionRecord> = Array()
    @Published var trackingRecords: Array<TrackingRecord> = Array()
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
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                isLocationAuthorized = deviceLocationSensorModel.isAuthorized
            }
        }
        
        locationDataSubscription = deviceLocationSensorModel.$data.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                locationRecords = deviceLocationSensorModel.data
            }
        }
        
        motionDataSubscription = deviceMotionSensorModel.$data.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                motionRecords = deviceMotionSensorModel.data
                
                if let location = deviceLocationSensorModel.data.last,
                   let motion = deviceMotionSensorModel.data.last {
                    
                    trackingRecords.append(TrackingRecord(location: location, motion: motion, timeStamp: Date().timeIntervalSince1970))
                }
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
        locationRecords.removeAll()
        motionRecords.removeAll()
        trackingRecords.removeAll()
    }
}
