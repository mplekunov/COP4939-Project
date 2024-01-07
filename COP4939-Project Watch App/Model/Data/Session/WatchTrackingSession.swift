//
//  Session.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 11/28/23.
//

import Foundation

struct WatchTrackingSession : Codable {
    let id: UUID
    let dateInSeconds: Double
    let data: Array<WatchTrackingRecord>
    
    init(uuid: UUID, dateInSeconds: Double, data: Array<WatchTrackingRecord>) {
        self.id = uuid
        self.data = data
        self.dateInSeconds = dateInSeconds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .uuid)
        self.data = try container.decode(Array<WatchTrackingRecord>.self, forKey: .data)
        self.dateInSeconds = try container.decode(Double.self, forKey: .dateInSeconds)
    }
    
    enum CodingKeys: CodingKey {
        case uuid
        case data
        case dateInSeconds
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .uuid)
        try container.encode(self.data, forKey: .data)
        try container.encode(self.dateInSeconds, forKey: .dateInSeconds)
    }
}
