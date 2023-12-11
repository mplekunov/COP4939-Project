//
//  Attitude.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/15/23.
//

import Foundation

struct Attitude : Codable, Equatable {
    var roll: Measurement<UnitAngle>
    var yaw: Measurement<UnitAngle>
    var pitch: Measurement<UnitAngle>
    
    init(roll: Measurement<UnitAngle>, yaw: Measurement<UnitAngle>, pitch: Measurement<UnitAngle>) {
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
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.pitch == rhs.pitch &&
        lhs.roll == rhs.roll &&
        lhs.yaw == rhs.yaw
    }
}
