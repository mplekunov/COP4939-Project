//
//  Attitude.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/23/23.
//

import Foundation

struct Attitude : Encodable, Decodable {
    var roll: Double = Double()
    var yaw: Double = Double()
    var pitch: Double = Double()
    
    init() {}
    
    init(roll: Double, yaw: Double, pitch: Double) {
        self.roll = roll
        self.yaw = yaw
        self.pitch = pitch
    }
    
    enum CodingKeys: CodingKey {
        case roll
        case yaw
        case pitch
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.roll, forKey: .roll)
        try container.encode(self.yaw, forKey: .yaw)
        try container.encode(self.pitch, forKey: .pitch)
    }
}
