//
//  DeviceMotionModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/12/23.
//

import Foundation
import CoreMotion

class DeviceMotionSensorViewModel : ObservableObject {
    private let motionManager: CMMotionManager = CMMotionManager()
    private let operationQueue: OperationQueue = OperationQueue()
    private let updateFrequency: Double
    private let logger: LoggerService
    
    @Published public private(set) var motion: MotionRecord?
    @Published public private(set) var error: String?
    @Published public private(set) var isRecording: Bool?
    
    init(updateFrequency: Double) {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        self.updateFrequency = updateFrequency
        
        motionManager.deviceMotionUpdateInterval = updateFrequency
        
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
        
        checkRequirements()
    }
    
    private func set(error: MotionManagerError?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.error = error?.description
        }
    }
    
    private func checkRequirements() {
        if motionManager.isDeviceMotionAvailable {
            set(error: .DeviceMotionNotAvailable)
        }
    }
    
    func startRecording() {
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            
            while true {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    motion = MotionRecord(
                        attitude: Attitude(
                            roll: Measurement(value: Double.random(in: -1...1), unit: .radians),
                            yaw: Measurement(value: Double.random(in: -1...1), unit: .radians),
                            pitch: Measurement(value: Double.random(in: -1...1), unit: .radians)
                        ),
                        acceleration: Unit3D(
                            x: Measurement(value: Double.random(in: -1...1), unit: .gravity),
                            y: Measurement(value: Double.random(in: -1...1), unit: .gravity),
                            z: Measurement(value: Double.random(in: -1...1), unit: .gravity)
                        ),
                        gForce: Unit3D(
                            x: Measurement(value: Double.random(in: -1...1), unit: .gravity),
                            y: Measurement(value: Double.random(in: -1...1), unit: .gravity),
                            z: Measurement(value: Double.random(in: -1...1), unit: .gravity)
                        ))
                }
                
                Thread.sleep(forTimeInterval: self.updateFrequency)
            }
        }
        
        motionManager.startDeviceMotionUpdates(to: operationQueue) { [weak self] motionData, error in
            guard let self = self else { return }
            
            if let motionData = motionData {
                let attitude = motionData.attitude
                let acceleration = motionData.userAcceleration
                let gForce = motionData.gravity
                
                // Update UI on main thread
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                     motion = MotionRecord(
                        attitude: Attitude(
                            roll: Measurement(value: attitude.roll, unit: .radians),
                            yaw: Measurement(value: attitude.yaw, unit: .radians),
                            pitch: Measurement(value: attitude.pitch, unit: .radians)
                        ),
                        acceleration: Unit3D(
                            x: Measurement(value: acceleration.x, unit: .gravity),
                            y: Measurement(value: acceleration.y, unit: .gravity),
                            z: Measurement(value: acceleration.z, unit: .gravity)
                        ),
                        gForce: Unit3D(
                            x: Measurement(value: gForce.x, unit: .gravity),
                            y: Measurement(value: gForce.y, unit: .gravity),
                            z: Measurement(value: gForce.z, unit: .gravity)
                        ))
                }
            }
            
            if let error = error {
                logger.error(message: "\(error)")
            }
        }
        
        isRecording = true
    }
    
    func stopRecording() {
        operationQueue.cancelAllOperations()
        motionManager.stopDeviceMotionUpdates()
        isRecording = false
    }
}
