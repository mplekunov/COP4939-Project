//
//  Session.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 11/28/23.
//

import Foundation

struct Session : Codable {
    let uuid: UUID
    let data: Array<CollectedData>
    
    init(uuid: UUID, data: Array<CollectedData>) {
        self.uuid = uuid
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.data = try container.decode(Array<CollectedData>.self, forKey: .data)
    }
    
    init() {
        uuid = UUID()
        data = Array()
    }
    
    enum CodingKeys: CodingKey {
        case uuid
        case data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.uuid, forKey: .uuid)
        try container.encode(self.data, forKey: .data)
    }
}
