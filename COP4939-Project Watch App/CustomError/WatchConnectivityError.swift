//
//  SenderError.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation

enum WatchConnectivityError : Error {
    case DeviceNotReachable
    case ConnectionNotActivated
    case ConnectedDeviceNotRecievedData
    case DeviceNotVerified
}
