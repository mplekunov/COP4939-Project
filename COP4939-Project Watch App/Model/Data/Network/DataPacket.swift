//
//  DataPacket.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import Foundation

struct DataPacket : Codable {
    let dataType: DataType
    let id: UUID
    let data: Data
    
    init(dataType: DataType, id: UUID, data: Data) {
        self.dataType = dataType
        self.id = id
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = try container.decode(DataType.self, forKey: .dataType)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.data = try container.decode(Data.self, forKey: .data)
    }
    
    enum CodingKeys: CodingKey {
        case dataType
        case id
        case data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.dataType, forKey: .dataType)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.data, forKey: .data)
    }
}
