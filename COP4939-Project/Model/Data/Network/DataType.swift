//
//  DataType.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import Foundation

enum DataType : Encodable, Decodable {
    case WatchSessionStart
    case WatchSessionEnd
    case WatchSession
    case DataDeliveryInformation
    case WatchConnectivityError
}
