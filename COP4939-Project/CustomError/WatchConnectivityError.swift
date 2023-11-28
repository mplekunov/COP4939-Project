//
//  WatchConnectivityError.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import Foundation

enum WatchConnectivityError : Error {
    case WatchNotPaired
    case WatchNotReachable
    case DeviceNotVerified
}
