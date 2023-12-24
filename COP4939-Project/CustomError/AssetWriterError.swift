//
//  AssetWriterError.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/24/23.
//

import Foundation

enum AssetWriterError : Error {
    case DirectoryIsUndefined
    case AssetWriterIsUndefined
    case AssetWriterInputIsUndefined
    case CannotAddInput
    case CreateAssetWriter(_ error: Error)
    case PixelBufferAdaptorIsUndefined
}

extension AssetWriterError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .DirectoryIsUndefined:
            "Directory for saving movie file is undefined."
        case .AssetWriterIsUndefined:
            "AssetWriter is undefined."
        case .AssetWriterInputIsUndefined:
            "AssetWriterInput is undefined."
        case .CannotAddInput:
            "Input cannot be added to the AssetWriter."
        case .CreateAssetWriter:
            "Cannot create capture input."
        case .PixelBufferAdaptorIsUndefined:
            "PixelBufferAdaptor is undefined."
        }
    }
}
