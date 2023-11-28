//
//  PairingData.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import Foundation

struct PairingVerification : Encodable, Decodable {
    let isVerified: Bool
    
    init(isVerified: Bool) {
        self.isVerified = isVerified
    }
    
    enum CodingKeys: CodingKey {
        case isVerified
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isVerified, forKey: .isVerified)
    }
}
