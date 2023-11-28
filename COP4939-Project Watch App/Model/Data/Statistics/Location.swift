//
//  Location.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/17/23.
//

import Foundation

struct Location : Encodable {
    var coordinate: Coordinate = Coordinate()
    var directionInDegrees: Double = Double()
    
    init() {}
    
    init(coordinate: Coordinate, directionInDegrees: Double) {
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
}
