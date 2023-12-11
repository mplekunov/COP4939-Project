//
//  Point3D.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/16/23.
//

import Foundation

class Unit3D<U> : Codable, Equatable where U: Dimension {
    var x: Measurement<U>
    var y: Measurement<U>
    var z: Measurement<U>
    
    required init(x: Measurement<U>, y: Measurement<U>, z: Measurement<U>) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    required init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Unit3D<U>.CodingKeys> = try decoder.container(keyedBy: Unit3D<U>.CodingKeys.self)
        self.x = try container.decode(Measurement<U>.self, forKey: Unit3D<U>.CodingKeys.x)
        self.y = try container.decode(Measurement<U>.self, forKey: Unit3D<U>.CodingKeys.y)
        self.z = try container.decode(Measurement<U>.self, forKey: Unit3D<U>.CodingKeys.z)
    }
    
    enum CodingKeys: CodingKey {
        case x
        case y
        case z
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<Unit3D<U>.CodingKeys> = encoder.container(keyedBy: Unit3D<U>.CodingKeys.self)
        try container.encode(self.x, forKey: Unit3D<U>.CodingKeys.x)
        try container.encode(self.y, forKey: Unit3D<U>.CodingKeys.y)
        try container.encode(self.z, forKey: Unit3D<U>.CodingKeys.z)
    }
    
    static func == (lhs: Unit3D<U>, rhs: Unit3D<U>) -> Bool {
        return lhs.x.value == rhs.x.value &&
            lhs.x.unit == rhs.x.unit &&
            lhs.y.value == rhs.y.value &&
            lhs.y.unit == rhs.y.unit &&
            lhs.z.value == rhs.z.value &&
            lhs.z.unit == rhs.z.unit
    }
}
