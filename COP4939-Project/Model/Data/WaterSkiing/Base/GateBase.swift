//
//  GateBase.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation

class GateBase<T> : Codable where T : Codable {
    let maxSpeed: Measurement<UnitSpeed>
    let maxRoll: Measurement<UnitAngle>
    let maxPitch: Measurement<UnitAngle>
    let position: T
    let timeOfRecordingInSeconds: Double
    
    init(maxSpeed: Measurement<UnitSpeed>, maxRoll: Measurement<UnitAngle>, maxPitch: Measurement<UnitAngle>, position: T, timeOfRecordingInSeconds: Double) {
        self.maxSpeed = maxSpeed
        self.maxRoll = maxRoll
        self.maxPitch = maxPitch
        self.position = position
        self.timeOfRecordingInSeconds = timeOfRecordingInSeconds
    }
}
