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
    
    private let logger: LoggerService
    
    private var dataSubscription: AnyCancellable?
    
    @Published public private(set) var trackingRecords: Array<BaseTrackingRecord> = Array()
    
    @Published var motionRecord: MotionRecord?
    
    @Published var error: String?
    
    @Published var isRecording = false
    
    init(
        deviceMotionSensorModel: DeviceMotionSensorViewModel
    ) {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        self.deviceMotionSensorModel = deviceMotionSensorModel
    
        deviceMotionSensorModel.$isRecording            
            .receive(on: DispatchQueue.main)
            .compactMap { isRecording in
                guard let motionIsRecording = isRecording else { return nil }
                
                return motionIsRecording
            }
            .assign(to: &$isRecording)
        
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
                guard let motion = deviceMotionSensorModel.motion else { return nil }
                
                return motion
            }
            .assign(to: &$motionRecord)
        
        dataSubscription = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .map { _ in Date() }
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard let motion = deviceMotionSensorModel.motion else { return }
                
                trackingRecords.append(BaseTrackingRecord(motion: motion, timeOfRecordingInSeconds: Date().timeIntervalSince1970))
            }
    }
    
    func startDataCollection() {
        deviceMotionSensorModel.startRecording()
    }
    
    func stopDataCollection() {
        deviceMotionSensorModel.stopRecording()
    }
    
    func clear() {
        trackingRecords.removeAll()
        motionRecord = nil
    }
}
