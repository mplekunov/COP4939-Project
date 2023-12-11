//
//  Location.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/17/23.
//

import Foundation

struct LocationRecord : Codable, Equatable {
    var coordinate: Coordinate
    var directionInDegrees: Measurement<UnitAngle>
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let coordinate = try container.decode(Coordinate.self, forKey: .coordinate)
        
        let directionInDegrees = try container.decode(Measurement<UnitAngle>.self, forKey: .directionInDegrees)
        
        self.coordinate = coordinate
        self.directionInDegrees = directionInDegrees
    }
    
    init(coordinate: Coordinate, directionInDegrees: Measurement<UnitAngle>) {
        self.coordinate = coordinate
        self.directionInDegrees = directionInDegrees
    }
    
    enum CodingKeys: CodingKey {
        case coordinate
        case directionInDegrees
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.coordinate, forKey: .coordinate)
        try container.encode(self.directionInDegrees, forKey: .directionInDegrees)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.coordinate == rhs.coordinate &&
        lhs.directionInDegrees == rhs.directionInDegrees
    }
}
