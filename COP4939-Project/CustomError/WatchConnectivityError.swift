//
//  WatchConnectivityError.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import Foundation

enum WatchConnectivityError : Error {
    case DeviceNotPaired
    case DeviceNotReachable
    case DeviceNotActivated
    case DeviceNotActive
    case WatchAppNotInstalled
    case UnknownStatus
}

extension WatchConnectivityError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .DeviceNotPaired:
            "Watch is not paired to the device."
        case .DeviceNotReachable:
            "Watch is not reachable."
        case .DeviceNotActive:
            "Device is not currently active."
        case .DeviceNotActivated:
            "Device is not activated."
        case .WatchAppNotInstalled:
            "Watch app is not installed on the watch."
        case .UnknownStatus:
            "Unknown Error"
        }
    }
}
