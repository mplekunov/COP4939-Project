//
//  ConnectivityErrorExtension.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation

extension WatchConnectivityError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .DeviceNotReachable:
            "Connected device is not reachable."
        case .ConnectedDeviceNotRecievedData:
            "Connected device has not recieved data."
        case .ConnectionNotActivated:
            "Connection is not activated."
        case .DeviceNotVerified:
            "This device is not ready to transfer data due to verification issue."
        }
    }
}
