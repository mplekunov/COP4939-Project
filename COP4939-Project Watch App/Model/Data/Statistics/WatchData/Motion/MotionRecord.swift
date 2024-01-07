//
//  MotionData.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/15/23.
//

import Foundation

struct MotionRecord : Codable, Equatable {
    var speed: Measurement<UnitSpeed>
    var attitude: Attitude
    var acceleration: Unit3D<UnitAcceleration>
    var gForce: Unit3D<UnitAcceleration>
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.attitude = try container.decode(Attitude.self, forKey: .attitude)
        self.acceleration = try container.decode(Unit3D<UnitAcceleration>.self, forKey: .acceleration)
        self.gForce = try container.decode(Unit3D<UnitAcceleration>.self, forKey: .gForce)
        self.speed = try container.decode(Measurement<UnitSpeed>.self, forKey: .speed)
    }
    
    init(speed: Measurement<UnitSpeed>, attitude: Attitude, acceleration: Unit3D<UnitAcceleration>, gForce: Unit3D<UnitAcceleration>) {
        self.attitude = attitude
        self.acceleration = acceleration
        self.gForce = gForce
        self.speed = speed
    }
    
    enum CodingKeys: CodingKey {
        case attitude
        case acceleration
        case gForce
        case speed
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(attitude, forKey: .attitude)
        try container.encode(acceleration, forKey: .acceleration)
        try container.encode(gForce, forKey: .gForce)
        try container.encode(speed, forKey: .speed)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.attitude == rhs.attitude &&
        lhs.acceleration == rhs.acceleration &&
        lhs.gForce == rhs.gForce &&
        lhs.speed == rhs.speed
    }
}
