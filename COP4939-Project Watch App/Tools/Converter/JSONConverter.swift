//
//  JSONConverter.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 12/4/23.
//

import Foundation

class JSONConverter {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    func decode<T>(_ type: T.Type, from: Data) throws -> T where T: Decodable {
        return try decoder.decode(type, from: from)
    }
    
    func encode<T>(_ data: T) throws -> Data where T: Encodable {
        return try encoder.encode(data)
    }
}
