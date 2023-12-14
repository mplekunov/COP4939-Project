//
//  Location.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/23/23.
//

import Foundation

struct LocationRecord : Codable, Equatable {
    var speed: Measurement<UnitSpeed>
    var coordinate: Coordinate
    var directionInDegrees: Measurement<UnitAngle>
    
    init(speed: Measurement<UnitSpeed>, coordinate: Coordinate, directionInDegrees: Measurement<UnitAngle>) {
        self.speed = speed
        self.coordinate = coordinate
        self.directionInDegrees = directionInDegrees
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.speed = try container.decode(Measurement<UnitSpeed>.self, forKey: .speed)
        self.coordinate = try container.decode(Coordinate.self, forKey: .coordinate)
        self.directionInDegrees = try container.decode(Measurement<UnitAngle>.self, forKey: .directionInDegrees)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.speed, forKey: .speed)
        try container.encode(self.coordinate, forKey: .coordinate)
        try container.encode(self.directionInDegrees, forKey: .directionInDegrees)
    }
    
    enum CodingKeys: CodingKey {
        case speed
        case coordinate
        case directionInDegrees
    }
}
