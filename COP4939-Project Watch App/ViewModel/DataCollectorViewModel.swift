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

    private var collectedDataSubscription: AnyCancellable?
    private var isLocationAuthorizedSubscription: AnyCancellable?
    
    private let logger: LoggerService
    
    @Published var locationRecords: Array<LocationRecord> = Array()
    @Published var motionRecords: Array<MotionRecord> = Array()
    @Published var trackingRecords: Array<TrackingRecord> = Array()
    
    @Published var isLocationAuthorized: Bool = false
    @Published var isRecording: Bool = false
    
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
        
        collectedDataSubscription = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .map { _ in Date() }.sink { [weak self] _ in
                guard let self = self else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if let last = deviceLocationSensorModel.data.last {
                        locationRecords.append(last)
                    }
                    
                    if let last = deviceMotionSensorModel.data.last {
                        motionRecords.append(last)
                    }
                    
                    if let location = deviceLocationSensorModel.data.last,
                       let motion = deviceMotionSensorModel.data.last {
                        
                        trackingRecords.append(TrackingRecord(location: location, motion: motion, timeStamp: Date().timeIntervalSince1970))
                    }
                }
            }
    }
    
    func startDataCollection() {
        deviceLocationSensorModel.startRecording()
        deviceMotionSensorModel.startRecording()
        
        isRecording = true
    }
    
    func stopDataCollection() {
        deviceMotionSensorModel.stopRecording()
        deviceLocationSensorModel.stopRecording()
        
        isRecording = false
    }
    
    func clearData() {
        locationRecords.removeAll()
        motionRecords.removeAll()
        trackingRecords.removeAll()
    }
}
