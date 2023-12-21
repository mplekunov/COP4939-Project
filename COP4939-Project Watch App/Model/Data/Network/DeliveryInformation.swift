//
//  DeliveryInformation.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation

struct DeliveryInformation : Codable {
    let id: UUID
    let isDelivered: Bool
    
    init(messageID: UUID, isDelivered: Bool) {
        self.id = messageID
        self.isDelivered = isDelivered
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .messageID)
        self.isDelivered = try container.decode(Bool.self, forKey: .isDelivered)
    }
    
    enum CodingKeys: CodingKey {
        case messageID
        case isDelivered
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .messageID)
        try container.encode(self.isDelivered, forKey: .isDelivered)
    }
}
