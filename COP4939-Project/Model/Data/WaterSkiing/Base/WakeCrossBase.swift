//
//  WakeCrossBase.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation

class WakeCrossBase<T> : Codable where T : Codable {
    let maxSpeed: Measurement<UnitSpeed>
    let maxRoll: Measurement<UnitAngle>
    let maxPitch: Measurement<UnitAngle>
    let maxAngle: Measurement<UnitAngle>
    let maxGForce: Measurement<UnitAcceleration>
    let maxAcceleration: Measurement<UnitAcceleration>
    let position: T
    let timeOfRecordingInSeconds: Double
    
    init(
        maxSpeed: Measurement<UnitSpeed>,
        maxRoll: Measurement<UnitAngle>,
        maxPitch: Measurement<UnitAngle>,
        maxAngle: Measurement<UnitAngle>,
        maxGForce: Measurement<UnitAcceleration>,
        maxAcceleration: Measurement<UnitAcceleration>,
        position: T,
        timeOfRecordingInSeconds: Double
    ) {
        self.maxSpeed = maxSpeed
        self.maxRoll = maxRoll
        self.maxPitch = maxPitch
        self.maxAngle = maxAngle
        self.maxGForce = maxGForce
        self.maxAcceleration = maxAcceleration
        self.position = position
        self.timeOfRecordingInSeconds = timeOfRecordingInSeconds
    }
}
