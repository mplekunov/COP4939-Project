//
//  MotionData.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/15/23.
//

import Foundation

struct MotionData : Encodable {
    var attitude: Attitude = Attitude()
    var acceleration: Point3D = Point3D()
    var gForce: Point3D = Point3D()
    
    init() {}
    
    init(attitude: Attitude, acceleration: Point3D, gForce: Point3D) {
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
}
