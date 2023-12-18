//
//  Location.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/17/23.
//

import Foundation

struct LocationRecord : Codable, Equatable {
    var speed: Measurement<UnitSpeed>
    var coordinate: Coordinate
    
    init(speed: Measurement<UnitSpeed>, coordinate: Coordinate) {
        self.speed = speed
        self.coordinate = coordinate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.speed = try container.decode(Measurement<UnitSpeed>.self, forKey: .speed)
        self.coordinate = try container.decode(Coordinate.self, forKey: .coordinate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.speed, forKey: .speed)
        try container.encode(self.coordinate, forKey: .coordinate)
    }
    
    enum CodingKeys: CodingKey {
        case speed
        case coordinate
    }
}
