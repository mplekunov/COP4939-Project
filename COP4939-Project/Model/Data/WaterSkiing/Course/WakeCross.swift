//
//  WaterCross.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/15/23.
//

import Foundation

struct WakeCross {
    public let location: Coordinate
    public let maxSpeed: Measurement<UnitSpeed>
    public let maxRoll: Measurement<UnitAngle>
    public let maxPitch: Measurement<UnitAngle>
    public let maxAngle: Measurement<UnitAngle>
    public let maxGForce: Measurement<UnitAcceleration>
    public let maxAcceleration: Measurement<UnitAcceleration>
    public let timeWhenPassed: Double
}
