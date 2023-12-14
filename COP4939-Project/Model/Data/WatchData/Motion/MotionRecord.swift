//
//  MotionData.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/23/23.
//

import Foundation

struct MotionRecord : Codable, Equatable {
    var attitude: Attitude
    var acceleration: Unit3D<UnitAcceleration>
    var gForce: Unit3D<UnitAcceleration>
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let attitude = try container.decode(Attitude.self, forKey: .attitude)
        
        let acceleration = try container.decode(Unit3D<UnitAcceleration>.self, forKey: .acceleration)
        
        let gForce = try container.decode(Unit3D<UnitAcceleration>.self, forKey: .gForce)
        
        self.attitude = attitude
        self.acceleration = acceleration
        self.gForce = gForce
    }
    
    init(attitude: Attitude, acceleration: Unit3D<UnitAcceleration>, gForce: Unit3D<UnitAcceleration>) {
        self.attitude = attitude
        self.acceleration = acceleration
        self.gForce = gForce
    }
    
    enum CodingKeys: CodingKey {
        case attitude
        case acceleration
        case gForce
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(attitude, forKey: .attitude)
        try container.encode(acceleration, forKey: .acceleration)
        try container.encode(gForce, forKey: .gForce)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.attitude == rhs.attitude &&
        lhs.acceleration == rhs.acceleration &&
        lhs.gForce == rhs.gForce
    }
}
