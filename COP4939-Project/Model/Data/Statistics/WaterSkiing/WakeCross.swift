//
//  WakeCross.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

struct WakeCross {
    let maxSpeed: Measurement<UnitSpeed>
    let maxRoll: Measurement<UnitAngle>
    let maxPitch: Measurement<UnitAngle>
    let maxAngle: Measurement<UnitAngle>
    let maxGForce: Measurement<UnitAcceleration>
    let maxAcceleration: Measurement<UnitAcceleration>
    
    init(
        maxSpeed: Measurement<UnitSpeed>,
        maxRoll: Measurement<UnitAngle>,
        maxPitch: Measurement<UnitAngle>,
        maxAngle: Measurement<UnitAngle>,
        maxGForce: Measurement<UnitAcceleration>,
        maxAcceleration: Measurement<UnitAcceleration>
    ) {
        self.maxSpeed = maxSpeed
        self.maxRoll = maxRoll
        self.maxPitch = maxPitch
        self.maxAngle = maxAngle
        self.maxGForce = maxGForce
        self.maxAcceleration = maxAcceleration
    }
}
