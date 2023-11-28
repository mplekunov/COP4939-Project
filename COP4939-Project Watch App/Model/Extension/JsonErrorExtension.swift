//
//  JsonError.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
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
