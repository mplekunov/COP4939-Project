//
//  WatchConnectivityErrorExtension.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import Foundation

extension WatchConnectivityError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .WatchNotPaired:
            "Watch is not paired to the device."
        case .WatchNotReachable:
            "Watch is not reachable."
        case .DeviceNotVerified:
            "This device is not ready to transfer data due to verification issue."
        }
    }
}
