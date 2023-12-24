//
//  MotionManagerError.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 12/23/23.
//

import Foundation

enum MotionManagerError : Error {
    case DeviceMotionNotAvailable
}

extension MotionManagerError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .DeviceMotionNotAvailable:
            "Decice motion sensor is not available on the device."
        }
    }
}
