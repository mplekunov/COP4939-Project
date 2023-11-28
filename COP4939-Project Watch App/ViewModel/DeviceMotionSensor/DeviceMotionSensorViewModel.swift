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
    
    @Published var data: Array<MotionData> = Array()
    
    private let floatingPointAccuracy = 3
    
    init(updateFrequency: Double) {
        self.updateFrequency = updateFrequency
        
        motionManager.deviceMotionUpdateInterval = updateFrequency
        
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
    }
    
    func startRecording() {
        motionManager.startDeviceMotionUpdates(to: operationQueue) { [weak self] motionData, error in
            guard let self = self else { return }
            
            if let motionData = motionData {
                let attitude = motionData.attitude
                let acceleration = motionData.userAcceleration
                let gForce = motionData.gravity
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.data.append(MotionData(
                        attitude: Attitude(
                            roll: attitude.roll.rounded(toPlaces: self.floatingPointAccuracy),
                            yaw: attitude.yaw.rounded(toPlaces: self.floatingPointAccuracy),
                            pitch: attitude.pitch.rounded(toPlaces: self.floatingPointAccuracy)
                        ),
                        acceleration: Point3D(
                            x: acceleration.x.rounded(toPlaces: self.floatingPointAccuracy),
                            y: acceleration.y.rounded(toPlaces: self.floatingPointAccuracy),
                            z: acceleration.z.rounded(toPlaces: self.floatingPointAccuracy)
                        ),
                        gForce: Point3D(
                            x: gForce.x.rounded(toPlaces: self.floatingPointAccuracy),
                            y: gForce.y.rounded(toPlaces: self.floatingPointAccuracy),
                            z: gForce.z.rounded(toPlaces: self.floatingPointAccuracy)
                        ))
                    )
                }
            }
            
            if let error = error {
                print("Internal Error: \(error)")
            }
        }
    }
    
    func stopRecording() {
        operationQueue.cancelAllOperations()
        motionManager.stopDeviceMotionUpdates()
    }
}
