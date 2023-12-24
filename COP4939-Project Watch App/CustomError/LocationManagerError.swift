//
//  LocationManagerError.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 12/23/23.
//

import Foundation

enum LocationManagerError : Error {
    case DeniedAuthorization
    case RestrictedAuthorization
    case UnknownAuthorization
}

extension LocationManagerError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .DeniedAuthorization:
            "App has been denied authorization to use Location Services."
        case .RestrictedAuthorization:
            "App usage of Location Services has been restricted."
        case .UnknownAuthorization:
            "App couldn't determine authorization status of Location Services."
        }
    }
}
