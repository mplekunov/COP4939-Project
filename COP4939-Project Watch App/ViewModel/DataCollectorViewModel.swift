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
    
    private let logger: LoggerService
    
    @Published public private(set) var trackingRecords: Array<TrackingRecord> = Array()
    
    private var combinedDataSubscription: AnyCancellable?
    
    @Published var locationRecord: LocationRecord?
    @Published var motionRecord: MotionRecord?
    
    @Published var error: String?
    
    @Published var isRecording = false
    
    init(
        deviceMotionSensorModel: DeviceMotionSensorViewModel,
        deviceLocationSensorModel: DeviceLocationSensorViewModel
    ) {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        self.deviceMotionSensorModel = deviceMotionSensorModel
        self.deviceLocationSensorModel = deviceLocationSensorModel
    
        deviceMotionSensorModel.$isRecording.combineLatest(deviceLocationSensorModel.$isRecording)
            .receive(on: DispatchQueue.main)
            .compactMap { recordingTuple in
                guard let motionIsRecording = recordingTuple.0 else { return nil }
                guard let locationIsRecording = recordingTuple.1 else { return nil }
                
                return motionIsRecording && locationIsRecording
            }
            .assign(to: &$isRecording)
        
        deviceLocationSensorModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { error in
                guard let error = error else { return nil }
                
                return error.description
            }
            .assign(to: &$error)
        
        deviceMotionSensorModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { error in
                guard let error = error else { return nil }
                
                return error.description
            }
            .assign(to: &$error)
        
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .map { _ in Date() }
            .compactMap { _ in
                guard let location = deviceLocationSensorModel.location else { return nil }
                
                return location
            }
            .assign(to: &$locationRecord)
        
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .map { _ in Date() }
            .compactMap { _ in
                guard let motion = deviceMotionSensorModel.motion else { return nil }
                
                return motion
            }
            .assign(to: &$motionRecord)
        
        combinedDataSubscription = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .map { _ in Date() }
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard let location = deviceLocationSensorModel.location else { return }
                guard let motion = deviceMotionSensorModel.motion else { return }
                
                trackingRecords.append(TrackingRecord(location: location, motion: motion, timeOfRecordingInSeconds: Date().timeIntervalSince1970))
            }
    }
    
    func startDataCollection() {
        deviceLocationSensorModel.startRecording()
        deviceMotionSensorModel.startRecording()
    }
    
    func stopDataCollection() {
        deviceMotionSensorModel.stopRecording()
        deviceLocationSensorModel.stopRecording()
    }
    
    func clear() {
        trackingRecords.removeAll()
        locationRecord = nil
        motionRecord = nil
    }
}
