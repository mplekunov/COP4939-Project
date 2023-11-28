//
//  JsonErrorExtension.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import Foundation

extension JsonError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .DecodingError:
            "Json couldn't be decoded."
        case .EncodingError:
            "Object couldn't be encoded to Json."
        }
    }
}
