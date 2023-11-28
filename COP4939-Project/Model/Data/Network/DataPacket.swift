//
//  DataPacker.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import Foundation

struct DataPacket : Encodable, Decodable {
    let dataType: DataType
    let data: Data
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        dataType = try container.decode(DataType.self, forKey: .dataType)
        data = try container.decode(Data.self, forKey: .data)
    }
    
    init(dataType: DataType, data: Data) {
        self.dataType = dataType
        self.data = data
    }
    
    enum CodingKeys: String, CodingKey {
        case dataType
        case data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.dataType, forKey: .dataType)
        try container.encode(self.data, forKey: .data)
    }
}
