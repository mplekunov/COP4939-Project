//
//  Stats.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/13/23.
//

import Foundation

struct Stats {
    let maxSpeed: Measurement<UnitSpeed>
    let maxRoll: Measurement<UnitAngle>
    let maxPitch: Measurement<UnitAngle>

    /// Optional additional properties for WakeCrossStats
    var maxAngle: Measurement<UnitAngle>?
    var maxGForce: Measurement<UnitAcceleration>?
    var maxAcceleration: Measurement<UnitAcceleration>?

    init(maxSpeed: Measurement<UnitSpeed>, maxRoll: Measurement<UnitAngle>, maxPitch: Measurement<UnitAngle>) {
        self.maxSpeed = maxSpeed
        self.maxRoll = maxRoll
        self.maxPitch = maxPitch
    }
    
    init(
        maxSpeed: Measurement<UnitSpeed>,
        maxRoll: Measurement<UnitAngle>,
        maxPitch: Measurement<UnitAngle>,
        maxAngle: Measurement<UnitAngle>,
        maxGForce: Measurement<UnitAcceleration>,
        maxAcceleration: Measurement<UnitAcceleration>
    ) {
        self.init(maxSpeed: maxSpeed, maxRoll: maxRoll, maxPitch: maxPitch)
        
        self.maxAngle = maxAngle
        self.maxGForce = maxGForce
        self.maxAcceleration = maxAcceleration
    }
}
