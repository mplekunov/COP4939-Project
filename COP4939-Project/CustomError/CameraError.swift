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
}
