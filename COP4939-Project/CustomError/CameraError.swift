//
//  CameraError.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/21/23.
//

import Foundation

enum CameraError: Error {
    case Unauthorized
    case DeniedAuthorization
    case RestrictedAuthorization
    case UnknownAuthorization
    case CameraUnavailable
    case CreateCaptureInput(_ error: Error)
    case CannotAddInput
    case CannotAddOutput
    case CameraNotConfigured
}


extension CameraError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .CameraNotConfigured:
            "Camera session is not configured"
        case .CameraUnavailable:
            "Camera is currently unavailable."
        case .CannotAddInput:
            "Cannot add input to the device."
        case .CannotAddOutput:
            "Cannot add output to the device."
        case .CreateCaptureInput:
            "Cannot create capture input."
        case .DeniedAuthorization:
            "App is has been denied authorization to use camera device."
        case .RestrictedAuthorization:
            "App usage of camera device has been restricted."
        case .Unauthorized:
            "App is not authorized to use camera device."
        case .UnknownAuthorization:
            "App couldn't determine authorization status of the camera device."
        }
    }
}
