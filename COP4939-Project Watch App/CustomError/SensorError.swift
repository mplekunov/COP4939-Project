//
//  SensorError.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/12/23.
//

import Foundation

enum SensorError : Error {
    case AccelerationSensorNotAvailable
    case AccelerationSensorNotActive
    case DeviceMotionSensorNotAvailable
    case DeviceMotionSensorNotActive
    case SensorRecordingNotStarting
    case SensorRecordingNotStopping
}
