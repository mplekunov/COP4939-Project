//
//  Coordinate.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/17/23.
//

import Foundation

struct Coordinate : Codable, Equatable {
    var latitude: Measurement<UnitAngle>
    var longitude: Measurement<UnitAngle>
    
    init(latitude: Measurement<UnitAngle>, longitude: Measurement<UnitAngle>) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    enum CodingKeys: CodingKey {
        case latitude
        case longitude
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude
    }
}
