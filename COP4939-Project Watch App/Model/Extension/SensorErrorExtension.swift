//
//  SensorError.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/18/23.
//

import Foundation

extension SensorError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .AccelerationSensorNotAvailable:
            "Acceleration sensor is not available on the device."
        case .AccelerationSensorNotActive:
            "Acceleration sensor is not active on the device."
        case .DeviceMotionSensorNotAvailable:
            "Device motion sensor is not availble on the device"
        case .DeviceMotionSensorNotActive:
            "Device motion sensor is not active on the device"
        case .SensorRecordingNotStarting:
            "Device sensor cannot be started."
        case .SensorRecordingNotStopping:
            "Device sensor cannot be stopped."
        }
    }
}
