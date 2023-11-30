//
//  Point3D.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/23/23.
//

import Foundation

struct Point3D : Codable, Equatable {
    var x = Double()
    var y = Double()
    var z = Double()
    
    init() {}
    
    init(x: Double = Double(), y: Double = Double(), z: Double = Double()) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    enum CodingKeys: CodingKey {
        case x
        case y
        case z
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.x, forKey: .x)
        try container.encode(self.y, forKey: .y)
        try container.encode(self.z, forKey: .z)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x &&
        lhs.y == rhs.y &&
        lhs.z == rhs.z
    }
}
