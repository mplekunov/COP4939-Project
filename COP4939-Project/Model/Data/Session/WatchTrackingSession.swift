//
//  Session.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/27/23.
//

import Foundation

struct WatchTrackingSession : Codable {
    let id: UUID
    let data: Array<TrackingRecord>
    
    init(uuid: UUID, data: Array<TrackingRecord>) {
        self.id = uuid
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .uuid)
        self.data = try container.decode(Array<TrackingRecord>.self, forKey: .data)
    }
    
    init() {
        id = UUID()
        data = Array()
    }
    
    enum CodingKeys: CodingKey {
        case uuid
        case data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .uuid)
        try container.encode(self.data, forKey: .data)
    }
}
